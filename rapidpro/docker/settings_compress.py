from .settings import *  # noqa

COMPRESS_ENABLED = True
COMPRESS_OFFLINE = True
COMPRESS_CSS_HASHING_METHOD = "content"
COMPRESS_OFFLINE_CONTEXT = dict(
    STATIC_URL="/sitestatic/",
    base_template="frame.html", brand=BRANDING[DEFAULT_BRAND], debug=False, testing=False
)
