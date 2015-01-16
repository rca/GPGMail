#/usr/bin/python

import os
import sys
import time
from datetime import datetime, timedelta

expirationDate = 0
if len(sys.argv) > 1:
    expirationDate = sys.argv[1]
if "GM_EXPIRATION_DATE" in os.environ:
    expirationDate = os.environ.get("GM_EXPIRATION_DATE")

if not expirationDate:
    expirationDate = datetime.now() + timedelta(days=1)

if isinstance(expirationDate, str):
    expirationDate = datetime.strptime(expirationDate, "%Y-%m-%d")

print int(time.mktime(expirationDate.utctimetuple()))



