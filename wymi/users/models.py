from django.db import models
from django.contrib.auth.models import User

from tastypie.models import ApiKey


class Profile(models.Model):
    user = models.OneToOneField(User, primary_key=True)
    location = models.CharField(max_length=255, blank=True)

    def __unicode__(self):
        return self.user.username

    @property
    def api_key(self):
        return ApiKey.objects.get(user=self.user)
