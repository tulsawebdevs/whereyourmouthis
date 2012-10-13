from django.contrib import admin

from .models import Facility, Inspection, Violation


class FacilityAdmin(admin.ModelAdmin):
    list_display = ('name', 'address', 'city', 'latitude', 'longitude', 'latest_score')
    list_filter = ('city',)
    search_fields = ('name',)


class InspectionAdmin(admin.ModelAdmin):
    list_display = ('facility', 'date', 'score')

admin.site.register(Facility, FacilityAdmin)
admin.site.register(Inspection, InspectionAdmin)
admin.site.register(Violation)
