# -------------------------------------------------------------------------------
# Name:        create_ADgroup_wMembers.py
# Purpose:     the purpose of the script is to create a new Active Directory security group in a specific 
# OU with Group Name, Description, and Notes. A text file is read in to populate membership of the new 
# group and AD permissions are authorized via .env and constants.py
#
# Author:      HHAY, PPLATTEN
#
# Created:     2025
# Copyright:   (c) Optimization Team 2025
# Licence:     mine
#
#
# usage: create_ADgroup_wMembers.py
# requirements (to be kept in same folder as main python file)::
#   1.) .env file with IDIR credentials, AD connection settings (server, domain, base DN, groups OU DN), 
# and target path for group membership text file.
#   2.) constants.py file to call on .env
#   3.) membership.txt file with list of IDIR usernames, they can be sAMAccountName or distinguishedName.
# -------------------------------------------------------------------------------

from ldap3 import Server, Connection, ALL, SUBTREE, MODIFY_ADD
import datetime
import getpass
import os
from constants import (
    IDIR_USER,
    IDIR_PASSWORD,
    AD_SERVER,
    AD_DOMAIN,
    AD_BASE_DN,
    GROUPS_OU_DN,
    MEMBERSHIP_FILE,
)


def connect_to_ad(server_name=AD_SERVER, domain=AD_DOMAIN):
    user = IDIR_USER
    password = IDIR_PASSWORD

    if not user or not password:
        print("IDIR credentials not found in environment. Prompting interactively...")
        user = input("Enter your IDIR username: ").strip()
        password = getpass.getpass("Enter your IDIR password: ")

    server = Server(server_name, get_info=ALL)
    conn = Connection(
        server, user=f"{domain}\\{user}", password=password, auto_bind=True
    )
    print(f"Connected to Active Directory server: {server_name} as {domain}\\{user}")
    return conn


def group_exists(conn, group_name, ou_dn=GROUPS_OU_DN):
    search_filter = f"(sAMAccountName={group_name})"
    conn.search(ou_dn, search_filter, SUBTREE, attributes=["cn"])
    return len(conn.entries) > 0


def resolve_user_dn(conn, member_line, base_dn=AD_BASE_DN):
    candidate = member_line.strip()
    if not candidate:
        return None
    lowered = candidate.lower()
    if lowered.startswith(("cn=", "ou=", "dc=")):
        return candidate
    search_filter = f"(sAMAccountName={candidate})"
    conn.search(base_dn, search_filter, SUBTREE, attributes=["distinguishedName"])
    return conn.entries[0].entry_dn if len(conn.entries) > 0 else None


def log_action(message):
    with open("group_creation_log.txt", "a", encoding="utf-8") as log_file:
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_file.write(f"[{timestamp}] {message}\n")


def main():
    conn = connect_to_ad()

    group_name = input("Enter the name for the new group: ").strip()
    description = input("Enter a description for the group: ").strip()
    notes = input("Enter notes (or press Enter to skip): ").strip()

    if not group_name:
        print("Group name cannot be empty.")
        log_action("Aborted: empty group name.")
        return

    if group_exists(conn, group_name, GROUPS_OU_DN):
        print(f"Error: Group '{group_name}' already exists in target OU.")
        log_action(f"Group '{group_name}' already exists. Aborted.")
        return

    attributes = {
        "sAMAccountName": group_name,
        "description": description,
        "groupType": "-2147483646",
    }
    if notes:
        attributes["info"] = notes

    group_dn = f"CN={group_name},{GROUPS_OU_DN}"
    print(f"Creating group '{group_name}' in OU:\n  {GROUPS_OU_DN}")
    conn.add(group_dn, ["group"], attributes)

    if conn.result["result"] == 0:
        print(f"Group '{group_name}' created successfully.")
        log_action(f"Group '{group_name}' created successfully.")
    else:
        print(f"Error creating group: {conn.result}")
        log_action(f"Failed to create group '{group_name}': {conn.result}")
        return

    # Membership file check
    members_file = MEMBERSHIP_FILE
    print(f"Looking for membership file: {members_file}")
    if not os.path.exists(members_file):
        print(f"Error: Membership file '{members_file}' not found.")
        log_action(f"Membership file '{members_file}' not found.")
        return

    with open(members_file, "r", encoding="utf-8") as f:
        members = [
            line.strip()
            for line in f
            if line.strip() and not line.strip().startswith("#")
        ]

    if not members:
        print("No members found in membership file.")
        log_action("No members found in membership file.")
        return

    for member in members:
        user_dn = resolve_user_dn(conn, member, AD_BASE_DN)
        if user_dn:
            print(f"Adding {member} to {group_name}...")
            conn.modify(group_dn, {"member": [(MODIFY_ADD, [user_dn])]})
            if conn.result["result"] == 0:
                log_action(f"Added '{member}' ({user_dn}) to group '{group_name}'.")
            else:
                log_action(
                    f"Failed to add '{member}' ({user_dn}) to group '{group_name}': {conn.result}"
                )
        else:
            print(f"User '{member}' not found in AD.")
            log_action(f"User '{member}' not found. Skipped.")

    print("All members processed. See 'group_creation_log.txt' for details.")


if __name__ == "__main__":
    main()
