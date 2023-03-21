import os
import warnings
from django.utils.translation import gettext_lazy as _

from .settings_common import *  # noqa


ADMINS=()

SEND_EMAILS = os.getenv("SEND_EMAILS", "False").lower() in ('true', '1', 'yes')
EMAIL_HOST = os.getenv("EMAIL_HOST", "localhost")
EMAIL_PORT = os.getenv("EMAIL_PORT", 587)
EMAIL_HOST_USER = os.getenv("EMAIL_HOST_USER", "server@temba.io")
EMAIL_HOST_PASSWORD = os.getenv("EMAIL_HOST_PASSWORD", "mypassword")
DEFAULT_FROM_EMAIL = os.getenv("DEFAULT_FROM_EMAIL", "server@temba.io")
EMAIL_USE_TLS = os.getenv("EMAIL_USE_TLS", "True").lower() in ('true', '1', 'yes')
EMAIL_TIMEOUT = 10

SECRET_KEY = os.getenv("SECRET_KEY", "your secret key")

_default_database_config = {
    "ENGINE": "django.contrib.gis.db.backends.postgis",
    "NAME": os.getenv("POSTGRES_DB","temba"),
    "USER": os.getenv("POSTGRES_USER","temba"),
    "PASSWORD": os.getenv("POSTGRES_PASSWORD","temba"),
    "HOST": os.getenv("POSTGRES_HOSTNAME","localhost"),
    "PORT": os.getenv("POSTGRES_PORT","5432"),
    "ATOMIC_REQUESTS": True,
    "CONN_MAX_AGE": 0,
    "OPTIONS": {},
    "DISABLE_SERVER_SIDE_CURSORS": True,
}
DATABASES = {"default": _default_database_config, "readonly": _default_database_config.copy()}
DEBUG = os.getenv("DEBUG", "False").lower() == 'true'
DOMAIN_NAME = os.getenv("DOMAIN_NAME","example.com")

STORAGE_URL = f"http://{DOMAIN_NAME}/media"
BRANDING = {
    DOMAIN_NAME: {
        "slug": "rapidpro",
        "name": "RapidPro",
        "org": "UNICEF",
        "colors": dict(primary="#0c6596"),
        "styles": ["brands/rapidpro/font/style.css"],
        "default_plan": TOPUP_PLAN,
        "welcome_topup": 1000,
        "email": "join@example.com",
        "support_email": "noreply@example.com",
        "link": f"https://{DOMAIN_NAME}",
        "api_link": f"https://{DOMAIN_NAME}",
        "docs_link": "http://docs.rapidpro.io",
        "domain": DOMAIN_NAME,
        "ticket_domain": "tickets.rapidpro.io",
        "favico": "brands/rapidpro/rapidpro.ico",
        "splash": "brands/rapidpro/splash.jpg",
        "logo": "brands/rapidpro/logo.png",
        "allow_signups": os.getenv("ALLOW_SIGNUPS", "False").lower() in ('true', '1', 'yes'),
        "flow_types": ["M", "V", "B", "S"],  # see Flow.FLOW_TYPES
        "location_support": True,
        "tiers": dict(multi_user=0, multi_org=0),
        "bundles": [],
        "welcome_packs": [dict(size=5000, name="Demo Account"), dict(size=100000, name="UNICEF Account")],
        "title": _("Visually build nationally scalable mobile applications"),
        "description": _("Visually build nationally scalable mobile applications from anywhere in the world."),
        "credits": "Copyright &copy; 2012-2022 UNICEF, Nyaruka. All Rights Reserved.",
        "support_widget": False,
    }
}
DEFAULT_BRAND = os.environ.get("DEFAULT_BRAND", DOMAIN_NAME)

ALLOWED_HOSTS = ["*", f".{DOMAIN_NAME}"]

REDIS_HOST = os.environ.get("REDIS_HOST", "localhost")
REDIS_PORT = 6379
REDIS_DB = 10 if TESTING else 15  # we use a redis db of 10 for testing so that we maintain caches for dev

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://%s:%s/%s" % (REDIS_HOST, REDIS_PORT, REDIS_DB),
        "OPTIONS": {"CLIENT_CLASS": "django_redis.client.DefaultClient"},
    }
}

INTERNAL_IPS = ("127.0.0.1",)

MAILROOM_HOST = os.environ.get("MAILROOM_HOST", "localhost")
MAILROOM_PORT = os.environ.get("MAILROOM_PORT", 8090)
MAILROOM_URL = "http://%s:%s" % (MAILROOM_HOST, MAILROOM_PORT)
MAILROOM_AUTH_TOKEN = os.environ.get("MAILROOM_AUTH_TOKEN", "")

INSTALLED_APPS = INSTALLED_APPS + ("storages", "tembaimporter", )

MIDDLEWARE = ("temba.middleware.ExceptionMiddleware",) + MIDDLEWARE

CELERY_TASK_ALWAYS_EAGER = True
CELERY_TASK_EAGER_PROPAGATES = True

warnings.filterwarnings(
    "error", r"DateTimeField .* received a naive datetime", RuntimeWarning, r"django\.db\.models\.fields"
)

STATIC_URL = "/sitestatic/"

COMPRESS_CACHEABLE_PRECOMPILERS = (
    'text/less',
)
