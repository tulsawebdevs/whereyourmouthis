from django.contrib.auth.models import User
from django.core import serializers
from django.db import models


class FacilityManager(models.Manager):
    def get_cleanest(self):
        return self.all().order_by('-latest_score')[:10]

    def get_cleanest_json(self):
        json_serializer = serializers.get_serializer("json")()
        return json_serializer.serialize(self.get_cleanest())


class Facility(models.Model):
    objects = FacilityManager()

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
    facility = models.ForeignKey('Facility', related_name='inspections')
    date = models.DateField()
    score = models.IntegerField(blank=True)
    type = models.CharField(max_length=255, blank=True)
    creator = models.ForeignKey(User, blank=True, null=True)

    def save(self, *args, **kwargs):
        super(Inspection, self).save(*args, **kwargs)
        self.facility.latest_score = self.facility.inspections.only(
            'score').latest('date').score
        self.facility.save()

    def __unicode__(self):
        return "%s: %s" % (self.facility.name, self.date)


class Violation(models.Model):
    inspection = models.ForeignKey('Inspection')
    type = models.CharField(max_length=255, blank=True)
    code = models.CharField(max_length=255, blank=True)
    details = models.CharField(max_length=255, blank=True)
    creator = models.ForeignKey(User, blank=True, null=True)

    def __unicode__(self):
        return "%s: %s: %s" % (self.inspection.facility, self.inspection.date,
                               self.type)
