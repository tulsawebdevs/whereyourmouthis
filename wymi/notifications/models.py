from django.db import models
from django.contrib.auth.models import User
from inspections.models import Facility

class Notification(models.Model):
    user = models.ForeignKey(User)
    facility = models.ForeignKey(Facility)
    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)
    text = models.CharField(max_length=140)
