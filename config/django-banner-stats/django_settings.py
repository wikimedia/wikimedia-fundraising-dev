# Django settings for fundraiser project.

DEBUG = True
TEMPLATE_DEBUG = DEBUG

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# On Unix systems, a value of None will cause Django to use the same
# timezone as the operating system.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = None # 'America/Chicago' # Setting to None to keep things in UTC

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale.
USE_L10N = True

# If you set this to False, Django will not use timezone-aware datetimes.
USE_TZ = False

# Make this unique, and don't share it with anybody.
SECRET_KEY = '1234567890'

INSTALLED_APPS = [
    'fundraiser.analytics'
]

# A sample logging configuration. The only tangible logging
# performed by this configuration is to send an email to
# the site admins on every HTTP 500 error when DEBUG=False.
# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': { },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler'
        },
        'mail_admins': {
            'level': 'ERROR',
            'filters': [],
            'class': 'django.utils.log.AdminEmailHandler'
        }
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
        'fundraiser': {
            'handlers': ['console'],
            'level': 'DEBUG'
        }
    }
}

DATABASES = {
	'default':{
		'ENGINE': 'django.db.backends.mysql',
		'NAME': 'dev_pgehres',
		'USER': 'root',
		'PASSWORD': '',
		'HOST': 'database',
		'PORT': '3306',
	}
}

UDP_LOG_PATH = "/tmp/banner_logs"

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache'
    },
    'country': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'country',
        'TIMEOUT': None,
        'MAX_ENTRIES': 3000,
    },
    'language': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'language',
        'TIMEOUT': None,
        'MAX_ENTRIES': 1000,
    },
    'project': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'project',
        'TIMEOUT': None,
    },
    'squid': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'squid',
        'TIMEOUT': None,
    },
}
