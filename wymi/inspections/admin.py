from django.contrib import admin

from .models import Facility, Inspection, Violation

admin.site.register(Facility)
admin.site.register(Inspection)
admin.site.register(Violation)
