# -*- coding: utf-8 -*-
import os

from ureport.settings_common import *

# INSTALLED_APPS = INSTALLED_APPS + ('debug_toolbar.apps.DebugToolbarConfig',)
# MIDDLEWARE = ('debug_toolbar.middleware.DebugToolbarMiddleware',) + MIDDLEWARE

ALLOWED_HOSTS = ['*']

DEBUG = os.getenv("DEBUG", "False").lower() == 'true'
THUMBNAIL_DEBUG = DEBUG


ADMINS=()

EMAIL_HOST = os.getenv("EMAIL_HOST", "localhost")
EMAIL_HOST_USER = os.getenv("EMAIL_HOST_USER", "server@temba.io")
EMAIL_HOST_PASSWORD = os.getenv("EMAIL_HOST_PASSWORD", "mypassword")
DEFAULT_FROM_EMAIL = os.getenv("DEFAULT_FROM_EMAIL", "server@temba.io")
EMAIL_USE_TLS = True
EMAIL_TIMEOUT = 10

SECRET_KEY = os.getenv("SECRET_KEY", "your secret key")


# for dev, have everything time out after six hours so we don't hit the server so much
API_BOUNDARY_CACHE_TIME = 60 * 60 * 6
API_GROUP_CACHE_TIME = 60 * 60 * 6
API_RESULT_CACHE_TIME = 60 * 60 * 6

SITE_API_HOST = os.getenv("RAPIDPRO_API_URL", 'https://api.rapidpro.io')

HOSTNAME = os.getenv("HOSTNAME", "ureport.io")

LOGGING['loggers']['celery.worker'] = {
    'level': 'DEBUG',
    'handlers': ['console'],
    'propagate': False,
}

if os.getenv('AWS_STORAGE_BUCKET_NAME', False):
    AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID', '')
    AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY', '')
    AWS_STORAGE_BUCKET_NAME = os.getenv('AWS_STORAGE_BUCKET_NAME')
    AWS_S3_REGION_NAME = os.getenv('AWS_S3_REGION_NAME', '')
    DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'


# these two settings will cause our aws files to never expire
# see http://developer.yahoo.com/performance/rules.html#expires
# AWS_QUERYSTRING_AUTH = False
# AWS_S3_OBJECT_PARAMETERS = {
#     'CacheControl': 'max-age=86400',
#
# }
# List of finder classes that know how to find static files in
# various locations.
# STATICFILES_FINDERS = (
#     'django.contrib.staticfiles.finders.FileSystemFinder',
#     'django.contrib.staticfiles.finders.AppDirectoriesFinder',
#     'compressor.finders.CompressorFinder',
# )

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        "NAME": os.getenv("POSTGRES_DB","temba"),
        "USER": os.getenv("POSTGRES_USER","temba"),
        "PASSWORD": os.getenv("POSTGRES_PASSWORD","temba"),
        "HOST": os.getenv("POSTGRES_HOSTNAME","localhost"),
        "PORT": os.getenv("POSTGRES_PORT","5432"),
        'ATOMIC_REQUESTS': True,
        'OPTIONS': {
        }
    }
}

CELERY_BROKER_URL = os.getenv("CELERY_BROKER_URL", 'redis://localhost:6379/1')

CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': CELERY_BROKER_URL,
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

CELERY_RESULT_BACKEND = CELERY_BROKER_URL

COMPRESS_CACHEABLE_PRECOMPILERS = (
    'text/coffeescript',
    'text/less',
)
