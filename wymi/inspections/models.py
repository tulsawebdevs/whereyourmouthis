from django.contrib.auth.models import User
from django.db import models

# Create your models here.
class Facility(models.Model):
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    state = models.CharField(max_length=5, blank=True)
    zip_code = models.CharField(max_length=10, blank=True)
    type = models.CharField(max_length=255, blank=True)
    creator = models.ForeignKey(User, blank=True, null=True)

class Inspection(models.Model):
    facility = models.ForeignKey('Facility')
    date = models.DateField()
    score = models.IntegerField(blank=True)
    type = models.CharField(max_length=255, blank=True)
    creator = models.ForeignKey(User, blank=True, null=True)

class Violation(models.Model):
    inspection = models.ForeignKey('Inspection')
    type = models.CharField(max_length=255, blank=True)
    details = models.CharField(max_length=255, blank=True)
    creator = models.ForeignKey(User, blank=True, null=True)
