from django.contrib.auth.models import User
from django.db import models

# Create your models here.
class Facility(models.Model):
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    state = models.CharField(max_length=5, blank=True)
    zip_code = models.CharField(max_length=10, blank=True)
    latitude = models.DecimalField('Latitude', max_digits=13, decimal_places=8,
                                  blank=True, null=True)
    longitude = models.DecimalField('Longitude', max_digits=13,
                                    decimal_places=8, blank=True, null=True)
    type = models.CharField(max_length=255, blank=True)
    creator = models.ForeignKey(User, blank=True, null=True)
    latest_score = models.IntegerField(blank=True, null=True)

    def __unicode__(self):
        return self.name

    class Meta:
        unique_together = (("name", "address"),)

class Inspection(models.Model):
    facility = models.ForeignKey('Facility')
    date = models.DateField()
    score = models.IntegerField(blank=True)
    type = models.CharField(max_length=255, blank=True)
    creator = models.ForeignKey(User, blank=True, null=True)

    def __unicode__(self):
        return "%s: %s" % (self.facility.name, self.date)

class Violation(models.Model):
    inspection = models.ForeignKey('Inspection')
    type = models.CharField(max_length=255, blank=True)
    details = models.CharField(max_length=255, blank=True)
    creator = models.ForeignKey(User, blank=True, null=True)

    def __unicode__(self):
        return "%s: %s: %s" % (self.inspection.facility, self.inspection.date,
                               self.type)
