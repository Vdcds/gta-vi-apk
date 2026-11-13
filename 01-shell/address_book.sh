#!/usr/bin/env bash
set -euo pipefail

ADDRESSBOOK=${ADDRESSBOOK:-addressbook.txt}
temporary=''
trap 'if [[ -n "$temporary" ]]; then rm -f -- "$temporary"; fi' EXIT

read_field() {
    IFS= read -r -p "$1" "$2" || exit 0
    if [[ ${!2} == *'|'* ]]; then
        echo "Fields cannot contain the | separator."
        return 1
    fi
}

has_record() {
    [[ -f "$ADDRESSBOOK" ]] && awk -F '|' -v name="$1" '
        tolower($1) == tolower(name) { found = 1 }
        END { exit !found }
    ' "$ADDRESSBOOK"
}

while true; do
    cat <<'MENU'
=================================
       ADDRESS BOOK MENU
=================================
1. Create Address Book
2. View Address Book
3. Insert a Record
4. Delete a Record
5. Modify a Record
6. Exit
=================================
MENU
    IFS= read -r -p 'Enter your choice: ' choice || exit 0
    case "$choice" in
        1)
            touch -- "$ADDRESSBOOK"
            echo "Address Book Created Successfully."
            ;;
        2)
            if [[ -f "$ADDRESSBOOK" ]]; then
                cat -- "$ADDRESSBOOK"
            else
                echo "Address Book does not exist."
            fi
            ;;
        3)
            read_field 'Enter Name: ' name || continue
            read_field 'Enter Phone Number: ' phone || continue
            read_field 'Enter Email: ' email || continue
            printf '%s|%s|%s\n' "$name" "$phone" "$email" >> "$ADDRESSBOOK"
            echo "Record Inserted Successfully."
            ;;
        4|5)
            read_field 'Enter Name to Find: ' name || continue
            if ! has_record "$name"; then
                echo "Record Not Found."
                continue
            fi
            if [[ "$choice" == 5 ]]; then
                read_field 'Enter New Name: ' newname || continue
                read_field 'Enter New Phone Number: ' newphone || continue
                read_field 'Enter New Email: ' newemail || continue
            fi
            temporary=$(mktemp "${ADDRESSBOOK}.XXXXXX")
            awk -F '|' -v name="$name" 'tolower($1) != tolower(name)' \
                "$ADDRESSBOOK" > "$temporary"
            if [[ "$choice" == 5 ]]; then
                printf '%s|%s|%s\n' "$newname" "$newphone" "$newemail" >> "$temporary"
            fi
            mv -- "$temporary" "$ADDRESSBOOK"
            temporary=''
            echo "Record Updated Successfully."
            ;;
        6) echo "Exiting Program..."; exit 0 ;;
        *) echo "Invalid Choice. Try Again." ;;
    esac
    echo
done
