from tastypie.resources import ModelResource
from .models import Facility, Inspection, Violation


class FacilityResource(ModelResource):
    class Meta:
        queryset = Facility.objects.all()

class InspectionResource(ModelResource):
    class Meta:
        queryset =  Inspection.objects.all()

class ViolationResource(ModelResource):
    class Meta:
        queryset = Violation.objects.all()
