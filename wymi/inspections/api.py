from decimal import Decimal as d
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
        ordering = ['latest_score']

    def build_filters(self, filters=None):
        if filters is None:
            filters = {}

        orm_filters = super(FacilityResource, self).build_filters(filters)

        if 'near' in filters:
            lat, lng, range = filters['near'].split(',')
            buffer_str = range
            low_lat = d(('%.5g' % d(lat))) - d(buffer_str)
            high_lat = d(('%.5g' % d(lat))) + d(buffer_str)
            low_lng = d(('%.5g' % d(lng))) - d(buffer_str)
            high_lng = d(('%.5g' % d(lng))) + d(buffer_str)

            orm_filters.update({'latitude__gte': low_lat,
                                'latitude__lte': high_lat,
                                'longitude__gte': low_lng,
                                'longitude__lte': high_lng})

        return orm_filters


class InspectionResource(ModelResource):
    facility = fields.ForeignKey(FacilityResource, 'facility')

    class Meta:
        queryset = Inspection.objects.all()
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
        filtering = {
            'inspection': ALL,
            'type': ALL,
            'code': ALL,
        }
