from django.conf import settings
from django.conf.urls.defaults import patterns, include, url
from django.contrib import admin
from django.views.generic import TemplateView

from tastypie.api import Api
from inspections.api import (FacilityResource, InspectionResource,
                             ViolationResource)

from home.views import HomeIndexView


admin.autodiscover()

v1_api = Api(api_name='v1')
v1_api.register(FacilityResource())
v1_api.register(InspectionResource())
v1_api.register(ViolationResource())

urlpatterns = patterns('',
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    url(r'^admin/', include(admin.site.urls)),
#    url(r'^api/v1/facility/?near=(?P<lat>),(?P<long>)&dist=(?P<dist>)'),
    url(r'^api/docs', TemplateView.as_view(template_name="api_docs.html"),
        name="api_docs"),
    url(r'^api/', include(v1_api.urls)),
    url(r'^$', HomeIndexView.as_view(), name="home"),
    url(r'', include('social_auth.urls')),
)
