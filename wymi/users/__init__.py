import json
import requests

from django.db import models as django_db_models
from django.contrib.auth.models import User

from social_auth.models import UserSocialAuth
from tastypie.models import create_api_key

from models import Profile

FACEBOOK_USER_GRAPH = 'https://graph.facebook.com/%s?access_token=%s'


def create_user_profile(username, **kwargs):
    user = User.objects.get(username=username)
    p = Profile.objects.create(user=user)
    usa = UserSocialAuth.objects.get(user=user)
    resp = requests.get(FACEBOOK_USER_GRAPH % (usa.extra_data['id'],
                                    usa.extra_data['access_token']))
    fb_user = json.loads(resp.content)
    p.location = fb_user['location']['name']
    p.save()

django_db_models.signals.post_save.connect(create_api_key, sender=User)
