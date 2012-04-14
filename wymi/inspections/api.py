from tastypie import fields
from tastypie.authentication import ApiKeyAuthentication
from tastypie.authorization import Authorization
from tastypie.resources import ModelResource, ALL
from .models import Facility, Inspection, Violation


class CreatorAuthorization(Authorization):
    def apply_limits(self, request, object_list):
        if request.method == 'GET':
            return object_list
        if request and hasattr(request, 'user'):
            if request.user.is_superuser:
                return object_list
            else:
                return object_list.filter(
                                    creator__username=request.user.username)

class FacilityResource(ModelResource):
    class Meta:
        queryset = Facility.objects.all()
        authentication = ApiKeyAuthentication()
        authorization = CreatorAuthorization()
        filtering = {
            'name': ALL,
            'address': ALL,
        }


class InspectionResource(ModelResource):
    facility = fields.ForeignKey(FacilityResource, 'facility')
    class Meta:
        queryset =  Inspection.objects.all()
        authentication = ApiKeyAuthentication()
        authorization = CreatorAuthorization()
        filtering = {
            'date': ALL,
            'facility': ALL,
        }

class ViolationResource(ModelResource):
    inspection = fields.ForeignKey(InspectionResource, 'inspection')
    class Meta:
        queryset = Violation.objects.all()
        authentication = ApiKeyAuthentication()
        authorization = CreatorAuthorization()
