"""
Django settings for SentimentAnalyzer project.

Generated by 'django-admin startproject' using Django 2.1.3.

For more information on this file, see
https://docs.djangoproject.com/en/2.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/2.1/ref/settings/
"""
import os
import dj_database_url
from .logger import logger

log = logger.get_logger(name=os.path.basename(__file__).split('.')[0], path=os.path.abspath(os.path.dirname(__file__)))

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/2.1/howto/deployment/checklist/

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True if 'DEBUG' in os.environ else False

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '4kcsz*@zui*aib-5yb-hi3=l+18s79bh)a#ni_2n0xq(5l%y@%' if 'SECRET_KEY' not in os.environ else os.environ['SECRET_KEY']

ALLOWED_HOSTS = [
    '.herokuapp.com',
]

if DEBUG:
    ALLOWED_HOSTS += ['localhost', '127.0.0.1', '[::1]']

# Application definition

APPS = [
    'server.apps.crawler',
    'server.apps.post',
]

THIRD_PARTY = [
    'rest_framework',
    'rest_framework.authtoken',
    # 'graphene_django',
]

DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY + APPS

MIDDLEWARE = [
    'django.middleware.cache.UpdateCacheMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.cache.FetchFromCacheMiddleware',
]

ROOT_URLCONF = 'server.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10
}

WSGI_APPLICATION = 'server.wsgi.application'

DEFAULT_CHARSET = 'utf8'
DATABASE_OPTIONS = dict(charset="utf8")

# Database
# https://docs.djangoproject.com/en/2.1/ref/settings/#databases

if 'DATABASE_URL' in os.environ:
    DATABASES = {
        'default': dj_database_url.config(default=os.environ['DATABASE_URL'])
    }

    # Patch MySQL
    if DATABASES['default']['ENGINE'] == 'django.db.backends.mysql':

        DATABASES['default']['OPTIONS'] = {
            'charset': 'utf8mb4',
            'use_unicode': True,
        }

        DATABASES['default']['TEST'] = {
            'CHARSET': 'utf8mb4',
            'COLLATION': 'utf8mb4_unicode_ci ',
        }

elif 'DB' in os.environ and os.environ['DB'] == "mysql":
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',
            'OPTIONS': {
                'charset': 'utf8mb4',
                'use_unicode': True,
            },
            'NAME': 'test_ci' if 'DB_NAME' not in os.environ else os.environ['DB_NAME'],
            'USER': 'root' if 'DB_USER' not in os.environ else os.environ['DB_USER'],
            'PASSWORD': '' if 'DB_PASSWORD' not in os.environ else os.environ['DB_PASSWORD'],
            'HOST': 'localhost' if 'DB_HOST' not in os.environ else os.environ['DB_HOST'],
            'TEST': {
                'CHARSET': 'utf8mb4',
                'COLLATION': 'utf8mb4_unicode_ci ',
            }
        }
    }
elif 'DB' in os.environ and os.environ['DB'] in ("postgresql", "postgres"):
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'test_ci' if 'DB_NAME' not in os.environ else os.environ['DB_NAME'],
            'USER': 'postgres' if 'DB_USER' not in os.environ else os.environ['DB_USER'],
            'PASSWORD': '' if 'DB_PASSWORD' not in os.environ else os.environ['DB_PASSWORD'],
            'HOST': 'localhost' if 'DB_HOST' not in os.environ else os.environ['DB_HOST'],
        }
    }
else:
    db_name = 'db.sqlite3'
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
        }
    }

# Password validation
# https://docs.djangoproject.com/en/2.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
# https://docs.djangoproject.com/en/2.1/topics/i18n/

LANGUAGE_CODE = 'en-us'

USE_I18N = True
USE_L10N = True

USE_TZ = True
TIME_ZONE = 'Mexico/General'

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/2.1/howto/static-files/

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')

# Extra places for collectstatic to find static files.
STATICFILES_DIRS = (os.path.join(BASE_DIR, 'staticfiles'),)
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'