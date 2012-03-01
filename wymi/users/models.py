from django.db import models
from django.contrib.auth.models import User


class Profile(models.Model):
    user = models.OneToOneField(User, primary_key=True)
    location = models.CharField(max_length=255, blank=True)

    def __unicode__(self):
        return self.user.username
