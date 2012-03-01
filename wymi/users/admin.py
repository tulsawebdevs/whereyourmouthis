from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User

from tastypie.admin import ApiKeyInline
from tastypie.models import ApiAccess, ApiKey

from .models import Profile

admin.site.register(ApiAccess)
admin.site.register(ApiKey)
admin.site.register(Profile)

class UserModelAdmin(UserAdmin):
    inlines = [ApiKeyInline]

admin.site.unregister(User)
admin.site.register(User, UserModelAdmin)
