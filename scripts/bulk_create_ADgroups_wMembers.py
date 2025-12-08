# -------------------------------------------------------------------------------
# Name:        bulk_create_ADgroup_wMembers.py
# Purpose:     the purpose of the script is to create a multiple new Active Directory security groups in a 
# specific OU. A csv file is read in to populate Group Name, Description, Notes and Membership of the new 
# groups. The Membership column in the csv file points to various text files listing group users. AD 
# permissions are authorized via .env and constants.py
#
# Author:      HHAY, PPLATTEN
#
# Created:     2025
# Copyright:   (c) Optimization Team 2025
# Licence:     mine
#
#
# usage: bulk_create_ADgroup_wMembers.py
# requirements:
#   1.) .env file with IDIR credentials, AD connection settings (server, domain, base DN, groups OU DN), 
# and target path for groups.csv file.
#   2.) constants.py file to call on .env
#   3.) groups.csv file with headers for Group Name, Description, Notes and Membership.
#   4.) various text files with list of IDIR usernames, they can be sAMAccountName or distinguishedName.
# -------------------------------------------------------------------------------

import csv
import os
import datetime
from ldap3 import Server, Connection, ALL, SUBTREE, MODIFY_ADD
import getpass
from constants import (
    IDIR_USER,
    IDIR_PASSWORD,
    AD_SERVER,
    AD_DOMAIN,
    AD_BASE_DN,
    GROUPS_OU_DN,
    BULK_CSV_PATH,
)
from datetime import datetime

# Generate timestamped log file name
LOG_FILE = f"bulk_group_creation_log_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
print(f"Log file for this run: {LOG_FILE}")


def log_action(message):
    with open(LOG_FILE, "a", encoding="utf-8") as log_file:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_file.write(f"[{timestamp}] {message}\n")


# ---- CSV Header Validation ----
EXPECTED_HEADERS = {"GroupName", "Description", "Notes", "MembershipFile"}


def validate_csv_headers(csv_path):
    """
    Validates that the CSV contains exactly the expected headers.
    Returns True if valid; otherwise prints details and returns False.
    """
    try:
        with open(csv_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            actual_headers = set(reader.fieldnames or [])
    except Exception as e:
        print(f"Error reading CSV '{csv_path}': {e}")
        log_action(f"Error reading CSV '{csv_path}': {e}")
        return False

    missing = EXPECTED_HEADERS - actual_headers
    extras = actual_headers - EXPECTED_HEADERS

    if missing or extras:
        print("CSV header validation failed.")
        print(f"  Missing headers: {sorted(missing) if missing else 'None'}")
        print(f"  Unexpected headers: {sorted(extras) if extras else 'None'}")
        log_action(
            f"CSV header validation failed. Missing: {sorted(missing) if missing else 'None'}; "
            f"Unexpected: {sorted(extras) if extras else 'None'}"
        )
        return False

    # Optional: enforce exact ordering (not strictly required by DictReader)
    # expected_order = ["GroupName", "Description", "Notes", "MembershipFile"]
    # if reader.fieldnames != expected_order:
    #     print(f"Warning: CSV headers present but not in expected order: {reader.fieldnames}")

    return True


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


def process_group(conn, group_name, description, notes, membership_file):
    metrics = {
        "created": False,
        "members_added": 0,
        "members_failed": 0,
        "members_not_found": 0,
    }

    if not group_name:
        print("Skipping: empty GroupName.")
        log_action("Skipped row with empty GroupName.")
        return metrics

    if group_exists(conn, group_name):
        print(f"Group '{group_name}' already exists in target OU. Skipping.")
        log_action(f"Group '{group_name}' already exists. Skipped.")
        return metrics

    attributes = {
        "sAMAccountName": group_name,
        "description": description or "",
        "groupType": "-2147483646",  # Global Security Group
    }
    if notes:
        attributes["info"] = notes

    group_dn = f"CN={group_name},{GROUPS_OU_DN}"
    print(f"Creating group '{group_name}' in OU:\n  {GROUPS_OU_DN}")
    conn.add(group_dn, ["group"], attributes)

    if conn.result["result"] == 0:
        metrics["created"] = True
        print(f"Group '{group_name}' created successfully.")
        log_action(f"Group '{group_name}' created successfully.")
    else:
        print(f"Error creating group '{group_name}': {conn.result}")
        log_action(f"Failed to create group '{group_name}': {conn.result}")
        return metrics

    if not membership_file or not os.path.exists(membership_file):
        print(
            f"Membership file '{membership_file}' not found for group '{group_name}'. Skipping members."
        )
        log_action(f"Membership file '{membership_file}' not found for '{group_name}'.")
        return metrics

    with open(membership_file, "r", encoding="utf-8") as f:
        members = [
            line.strip()
            for line in f
            if line.strip() and not line.strip().startswith("#")
        ]

    if not members:
        print(f"No members found in '{membership_file}' for group '{group_name}'.")
        log_action(f"No members found in '{membership_file}' for '{group_name}'.")
        return metrics

    for member in members:
        user_dn = resolve_user_dn(conn, member)
        if user_dn:
            print(f"Adding {member} to {group_name}...")
            conn.modify(group_dn, {"member": [(MODIFY_ADD, [user_dn])]})
            if conn.result["result"] == 0:
                metrics["members_added"] += 1
                log_action(f"Added '{member}' ({user_dn}) to group '{group_name}'.")
            else:
                metrics["members_failed"] += 1
                log_action(
                    f"Failed to add '{member}' ({user_dn}) to group '{group_name}': {conn.result}"
                )
        else:
            metrics["members_not_found"] += 1
            print(f"User '{member}' not found in AD (for group '{group_name}').")
            log_action(f"User '{member}' not found for '{group_name}'. Skipped.")

    return metrics


def main():
    # Validate CSV path exists
    csv_file = BULK_CSV_PATH
    print(f"Using bulk CSV file: {csv_file}")
    if not os.path.exists(csv_file):
        print(f"Error: CSV file '{csv_file}' not found.")
        log_action(f"CSV file '{csv_file}' not found. Aborted.")
        return

    # Validate CSV headers before doing anything else
    if not validate_csv_headers(csv_file):
        print("Aborting due to invalid CSV headers.")
        return

    conn = connect_to_ad()

    print(f"Target OU (from .env): {GROUPS_OU_DN}")
    print("Mode: LIVE (changes will be applied)")

    totals = {
        "rows": 0,
        "groups_created": 0,
        "groups_skipped_exists": 0,
        "members_added": 0,
        "members_failed": 0,
        "members_not_found": 0,
    }

    with open(csv_file, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            totals["rows"] += 1
            group_name = (row.get("GroupName") or "").strip()
            description = (row.get("Description") or "").strip()
            notes = (row.get("Notes") or "").strip()
            membership_file = (row.get("MembershipFile") or "").strip()

            if group_name and group_exists(conn, group_name):
                print(f"Group '{group_name}' already exists in target OU. Skipping.")
                log_action(f"Group '{group_name}' already exists. Skipped (pre-check).")
                totals["groups_skipped_exists"] += 1
                continue

            metrics = process_group(
                conn, group_name, description, notes, membership_file
            )
            if metrics["created"]:
                totals["groups_created"] += 1

            totals["members_added"] += metrics["members_added"]
            totals["members_failed"] += metrics["members_failed"]
            totals["members_not_found"] += metrics["members_not_found"]

    print("\n=== Bulk Processing Summary ===")
    print(f"Rows processed:       {totals['rows']}")
    print(f"Groups created:       {totals['groups_created']}")
    print(f"Groups skipped (exist): {totals['groups_skipped_exists']}")
    print(f"Members added:        {totals['members_added']}")
    print(f"Members failed:       {totals['members_failed']}")
    print(f"Members not found:    {totals['members_not_found']}")
    print(f"Log file: {LOG_FILE}")


if __name__ == "__main__":
    main()
