from django.db import models
from django.contrib.auth.models import User

from tastypie.models import create_api_key

# Hook up api key auto-generation for new users
models.signals.post_save.connect(create_api_key, sender=User)
