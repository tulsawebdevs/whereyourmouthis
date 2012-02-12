from tastypie import fields
from tastypie.resources import ModelResource
from .models import Facility, Inspection, Violation


class FacilityResource(ModelResource):
    class Meta:
        queryset = Facility.objects.all()

class InspectionResource(ModelResource):
    facility = fields.ForeignKey(FacilityResource, 'facility')
    class Meta:
        queryset =  Inspection.objects.all()

class ViolationResource(ModelResource):
    inspection = fields.ForeignKey(InspectionResource, 'inspection')
    class Meta:
        queryset = Violation.objects.all()
