import os

DB_PATCH = os.getenv("DB_PATCH", "x-ui.db")
SERVER_ADDRESS = os.getenv("SERVER_ADDRESS", "localhost")
SERVER_PORT = os.getenv("SERVER_PORT", 8000)
PUBLIC_KEY = os.getenv("PUBLIC_KEY", "BS5Yv5xIQ8aGlUmJRaYxye9f_yfrv-Q348tAPmJdaFs")
SID = os.getenv("SID", "06d31f198f3dd6")
SNI = os.getenv("SNI", "google.com")
FP = os.getenv("FP", "safari")
TYPE = os.getenv("TYPE", "tcp")
SECURITY = os.getenv("SECURITY", "reality")
SPX = os.getenv("SPX", "%2F")
FLOW = os.getenv("FLOW", "xtls-rprx-vision")