from django.conf.urls.defaults import patterns, include, url
from django.contrib import admin
admin.autodiscover()

from inspections.api import (FacilityResource, InspectionResource,
                             ViolationResource)


facility_resource = FacilityResource()
inspection_resource = InspectionResource()
violation_resource = ViolationResource()

urlpatterns = patterns('',
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^api/', include(facility_resource.urls)),
    url(r'^api/', include(inspection_resource.urls)),
    url(r'^api/', include(violation_resource.urls)),
)
