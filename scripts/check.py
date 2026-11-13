#!/usr/bin/env python3
"""Run the programs and check the behavior visible to their users."""

from pathlib import Path
import os
import re
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]


def run(*command, text=None, success=True, env=None):
    result = subprocess.run(
        command, cwd=ROOT, input=text, text=True, capture_output=True,
        timeout=15, env=env,
    )
    if success:
        assert result.returncode == 0, (command, result.stdout, result.stderr)
    else:
        assert result.returncode != 0, (command, result.stdout)
    return result.stdout


def check_address_book():
    with tempfile.TemporaryDirectory(prefix="oslab-check-") as directory:
        book = Path(directory) / "address book.txt"
        environment = dict(os.environ, ADDRESSBOOK=str(book))
        # The dot must match literally, rather than matching any character.
        text = "1\n3\nA.B\n123\na@b.test\n3\nAxB\n456\nx@b.test\n4\na.b\n6\n"
        run("bash", "01-shell/address_book.sh", text=text, env=environment)
        assert book.read_text() == "AxB|456|x@b.test\n"
        text = "5\naxb\nNew Name\n789\nnew@b.test\n2\n6\n"
        output = run("bash", "01-shell/address_book.sh", text=text, env=environment)
        assert "New Name|789|new@b.test" in output
        assert book.read_text() == "New Name|789|new@b.test\n"
        run("bash", "01-shell/address_book.sh", text="4\nNew Name\n6\n", env=environment)
        assert book.read_text() == ""
        run("bash", "01-shell/address_book.sh", text="", env=environment)
    print("PASS address book: insert, literal name lookup, modify, delete, and EOF")


def check_processes():
    output = run("./run.sh", "2a", "--demo")
    assert "Sorted Array by Child: 10 20 30 40 50" in output
    assert "Sorted Array by Parent: 10 20 30 40 50" in output
    assert output.index("CHILD PROCESS") < output.index("PARENT PROCESS")
    run("build/fork_sort", text="0\n", success=False)
    zombie = subprocess.Popen(
        [str(ROOT / "build/zombie")], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, cwd=ROOT,
    )
    try:
        # Read the parent line even if the child's message appears first.
        first = zombie.stdout.readline()
        if not first.startswith("Parent PID"):
            first = zombie.stdout.readline()
        child = re.search(r"child PID = (\d+)", first).group(1)
        observed = False
        for _ in range(50):
            status = subprocess.run(
                ["ps", "-o", "stat=", "-p", child], text=True, capture_output=True,
                timeout=5,
            ).stdout.strip()
            if status.startswith("Z"):
                observed = True
                break
            time.sleep(0.02)
        assert observed, "Child never entered the zombie state"
        remainder, error = zombie.communicate(timeout=10)
        assert zombie.returncode == 0, error
        assert "Parent reaped child" in remainder
    finally:
        if zombie.poll() is None:
            zombie.kill()
            zombie.communicate()
    output = run("./run.sh", "2c")
    old = re.search(r"Original parent PID = (\d+)", output).group(1)
    new = re.search(r"New parent PID = (\d+)", output).group(1)
    assert old != new, output
    print("PASS processes: both sorts, observed zombie state, and orphan reparenting")


def check_threads():
    for _ in range(5):
        output = run("./run.sh", "3")
        produced = list(map(int, re.findall(r"Producer produced: (\d+)", output)))
        consumed = list(map(int, re.findall(r"Consumer consumed: (\d+)", output)))
        assert produced == consumed == list(range(10, 101, 10)), output
        output = run("./run.sh", "4")
        for philosopher in range(5):
            meals = re.findall(rf"Philosopher {philosopher} is Eating \(meal (\d)\)", output)
            assert meals == ["1", "2", "3"], output
    print("PASS threads: all items consumed in order and each philosopher finishes 3 meals")


def check_bankers():
    output = run("./run.sh", "5", "--demo")
    assert "Safe Sequence: P0 -> P2 -> P3 -> P4 -> P1" in output
    output = run("build/bankers", text="2 1\n1\n1\n2\n2\n0\n")
    assert "NOT in Safe State" in output
    run("build/bankers", text="1 1\n2\n1\n0\n", success=False)
    run("build/bankers", text="0\n", success=False)
    print("PASS Banker's algorithm: safe, unsafe, and invalid input")


def check_ipc():
    sentence = "Operating Systems laboratory experiment"
    output = run("./run.sh", "6", "--demo")
    for expected in (f"Characters = {len(sentence)}", "Words = 4", "Lines = 1"):
        assert expected in output, output
    assert (ROOT / "build/fifo-result.txt").read_text() in output
    output = run("./run.sh", "fifo", text="\n")
    assert "Characters = 0" in output and "Words = 0" in output and "Lines = 0" in output
    run("./run.sh", "fifo", text="x" * 500 + "\n", success=False)
    run("./run.sh", "fifo", text="", success=False)
    run("./run.sh", "fifo", text="Hello again\n")
    assert not (ROOT / "fifo1").exists() and not (ROOT / "fifo2").exists()
    print("PASS FIFOs: sentence statistics, empty input, rejection, and repeated runs")


def check_pipes():
    output = run("./run.sh", "7", "--demo")
    assert output == "Contents of File:\n" + (ROOT / "samples/sample.txt").read_text()
    with tempfile.TemporaryDirectory(prefix="oslab-pipe-") as directory:
        file = Path(directory) / "file with spaces.txt"
        content = "File content larger than one pipe buffer.\n" * 10000
        file.write_text(content)
        output = run("./run.sh", "pipe_file", str(file))
        assert output == "Contents of File:\n" + content
        file.write_text("")
        assert run("build/pipe_file", str(file)) == "Contents of File:\n"
        output = run("build/pipe_file", str(file) + ".missing", success=False)
        assert "Cannot open file" in output
    print("PASS pipes: exact transfer of sample, large file, empty file, and missing file")


def disk_result(program, text):
    output = run("build/" + program, text=text)
    sequence = list(map(int, re.search(r"Seek Sequence: ([\d >-]+)", output).group(1).split(" -> ")))
    total = int(re.search(r"Total Seek Operations = (\d+)", output).group(1))
    return sequence, total


def check_disk():
    sample = (ROOT / "samples/disk.in").read_text()
    expected = {
        "sstf": ([100, 90, 58, 55, 39, 38, 18, 150, 160, 184], 248),
        "scan": ([100, 150, 160, 184, 199, 90, 58, 55, 39, 38, 18], 280),
        "clook": ([100, 150, 160, 184, 18, 38, 39, 55, 58, 90], 322),
    }
    cases = [
        ("2\n10 20\n100\n", {
            "sstf": ([100, 20, 10], 90),
            "scan": ([100, 199, 20, 10], 288),
            "clook": ([100, 10, 20], 100),
        }),
        ("2\n150 160\n100\n", {
            "sstf": ([100, 150, 160], 60),
            "scan": ([100, 150, 160, 199], 99),
            "clook": ([100, 150, 160], 60),
        }),
        ("3\n100 100 0\n100\n", {
            "sstf": ([100, 100, 100, 0], 100),
            "scan": ([100, 100, 100, 199, 0], 298),
            "clook": ([100, 100, 100, 0], 100),
        }),
    ]
    for program, result in expected.items():
        assert disk_result(program, sample) == result
        for text, results in cases:
            assert disk_result(program, text) == results[program], (program, text)
        for invalid in ("0\n", "1\n200\n100\n", "1\n10\n-1\n", "abc\n"):
            run("build/" + program, text=invalid, success=False)
        run("./run.sh", program, "--demo")
    print("PASS disk scheduling: exact sequences, totals, duplicates, and input bounds")


def check_menu():
    with tempfile.TemporaryDirectory(prefix="oslab-editor-") as directory:
        fake_code = Path(directory) / "code"
        fake_code.write_text('#!/usr/bin/env bash\nprintf "%s\\n" "$@" >> "$OSLAB_EDITOR_LOG"\n')
        fake_code.chmod(0o755)
        log = Path(directory) / "opened files.txt"
        environment = dict(os.environ, PATH=directory + os.pathsep + os.environ["PATH"],
                           OSLAB_EDITOR_LOG=str(log), OSLAB_SKIP_EDITOR="0")
        output = run("bash", "scripts/menu.sh", text="wrong\n5\n\n\n6\n\n\n8b\n\n\nq\n", env=environment)
        assert "Choose an ID from the list" in output
        assert "Safe Sequence: P0 -> P2 -> P3 -> P4 -> P1" in output
        assert "Number of Characters = 39" in output
        assert "Total Seek Operations = 280" in output
        opened = log.read_text()
        for path in ("05-deadlock-avoidance/bankers.c", "06-ipc/process1.c",
                     "06-ipc/process2.c", "08-disk/scan.c", "cheats/05-BANKERS.txt",
                     "cheats/06-FIFO-IPC.txt", "cheats/08-DISK-SCHEDULING.txt"):
            assert path in opened, path
        output = run("bash", "scripts/menu.sh", text="2a\nn\n3\n9 1 4\n\nq\n", env=environment)
        assert "Sorted Array by Child: 1 4 9" in output
        assert "Sorted Array by Parent: 1 4 9" in output
        run("bash", "scripts/menu.sh", text="", env=environment)
    print("PASS practical menu: source and cheat opening, sample runs, custom input, and exit")


def check_ubuntu_launcher():
    with tempfile.TemporaryDirectory(prefix="oslab-ubuntu-") as directory:
        work = Path(directory)
        desktop = work / "My Desktop"
        fake_bin = work / "bin"
        fake_bin.mkdir()
        log = work / "VS Code opened files.txt"
        code = fake_bin / "code"
        code.write_text('#!/usr/bin/env bash\nprintf "%s\\n" "$@" >> "$OSLAB_EDITOR_LOG"\n')
        code.chmod(0o755)
        environment = dict(os.environ, PATH=str(fake_bin) + os.pathsep + os.environ["PATH"],
                           OSLAB_EDITOR_LOG=str(log), OSLAB_DESKTOP_DIR=str(desktop))
        output = run("bash", "UBUNTU-START.sh", text="5\n\n\nq\n", env=environment)
        project = desktop / "gta-vi-apk"
        assert "Safe Sequence: P0 -> P2 -> P3 -> P4 -> P1" in output
        assert (project / "build/bankers").exists(), "Program did not compile in the Desktop copy"
        assert not (project / "build/fork_sort").exists(), "Old binaries were copied"
        assert not (project / ".git").exists()
        assert not (project / "addressbook.txt").exists()
        assert (project / ".vscode/tasks.json").exists()
        assert (project / "common/input.h").exists()
        for original in (ROOT / "originals").iterdir():
            assert (project / "originals" / original.name).read_bytes() == original.read_bytes()
        opened = log.read_text()
        assert str(project / "cheats/00-UBUNTU-START.txt") in opened
        assert str(project / "cheats/05-BANKERS.txt") in opened
        assert "05-deadlock-avoidance/bankers.c" in opened
        (project / "README.md").write_text("My Desktop edits\n")
        run("bash", "UBUNTU-START.sh", text="q\n", env=environment)
        assert (project / "README.md").read_text() == "My Desktop edits\n"
        assert len(list(desktop.iterdir())) == 2, "Repeated copying should preserve the first project"
        run("bash", str(project / "UBUNTU-START.sh"), text="q\n", env=environment)
        assert len(list(desktop.iterdir())) == 2, "Running a Desktop copy should reuse it"
        # Exercise localized Desktop discovery without relying on this host's settings.
        xdg = fake_bin / "xdg-user-dir"
        xdg.write_text('#!/usr/bin/env bash\nprintf "%s\\n" "$OSLAB_TEST_XDG_DESKTOP"\n')
        xdg.chmod(0o755)
        localized = work / "Bureau du labo"
        environment.pop("OSLAB_DESKTOP_DIR")
        environment["OSLAB_TEST_XDG_DESKTOP"] = str(localized)
        run("bash", "UBUNTU-START.sh", text="q\n", env=environment)
        assert (localized / "gta-vi-apk/run.sh").exists()
    print("PASS Ubuntu launcher: Desktop copy, compilation, editor arguments, original bytes, repeat runs, and localized paths")


if __name__ == "__main__":
    check_address_book()
    run("./run.sh", "1", "--demo")
    check_processes()
    check_threads()
    check_bankers()
    check_ipc()
    check_pipes()
    check_disk()
    check_menu()
    check_ubuntu_launcher()
    print("All 13 programs passed.")
