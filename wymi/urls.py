from django.conf.urls.defaults import patterns, include, url
from django.conf import settings
from django.contrib import admin
from django.views.generic import TemplateView

from tastypie.api import Api

from inspections.api import (FacilityResource, InspectionResource,
                             ViolationResource)
from inspections.views import (region, region_json, AppCacheTemplateView,
                               load as iv_load)


admin.autodiscover()

v1_api = Api(api_name='v1')
v1_api.register(FacilityResource())
v1_api.register(InspectionResource())
v1_api.register(ViolationResource())

urlpatterns = patterns('',
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^api/', include(v1_api.urls)),
    url(r'^$', TemplateView.as_view(template_name="home/index.html"),
        name="home"),
    url(r'^location/(\d+)/?',
        TemplateView.as_view(template_name="home/index.html"),
        name="home"),
    url(r'^inspections/load/?$', iv_load, name='inspections_load'),
    url(r'^region$', region, name='region'),
    url(r'^(?P<region>\w+).json$', region_json, name="region_json"),
    url(r'^wymi.appcache', AppCacheTemplateView.as_view(
        template_name="appcache.txt"), name="appcache")
)

urlpatterns += patterns('',
    url(r'^static/<?P<path>.*)$', 'django.views.static.server',
        {'document_root': settings.STATIC_ROOT}),
)
