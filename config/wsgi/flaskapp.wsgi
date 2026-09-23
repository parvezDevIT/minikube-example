#!/usr/bin/python3
import sys
import site

# 1. First, tell Apache where your pip dependencies are installed (Python 3.11)
# site.addsitedir('/usr/local/lib/python3.11/site-packages')

# 2. Next, add your Flask application directory to the system path
sys.path.insert(0, "/var/www/flaskapp")

# 3. Last, perform the import AFTER the paths have been safely configured
from run import app as application

