import os
from dotenv import load_dotenv, find_dotenv

env_path = find_dotenv()
if env_path:
    print("loading dot env...")
    load_dotenv(env_path)

IDIR_USER = os.getenv("IDIR_USER")
IDIR_PASSWORD = os.getenv("IDIR_PASSWORD")

AD_SERVER = os.getenv("AD_SERVER", "IDIR")
AD_DOMAIN = os.getenv("AD_DOMAIN", "IDIR")
AD_BASE_DN = os.getenv("AD_BASE_DN", "DC=idir,DC=BCGOV")

GROUPS_OU_DN = os.getenv(
    "GROUPS_OU_DN",
    "OU=GeoDrive Client File Server,OU=LOB Servers,OU=Line of Business,OU=Forests,OU=BCGOV,DC=idir,DC=BCGOV",
)

MEMBERSHIP_FILE = os.getenv("MEMBERSHIP_FILE", "membership.txt")
BULK_CSV_PATH = os.getenv("BULK_CSV_PATH", "groups.csv")
