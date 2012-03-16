import json
import requests

from django.core.management.base import BaseCommand
from social_auth.models import UserSocialAuth


FACEBOOK_GRAPH_HOST = 'https://graph.facebook.com'

class Command(BaseCommand):
    help = "Create notifications for users."

    def handle(self, *args, **kwargs):
        for usa in UserSocialAuth.objects.all():
            u = usa.user
            print "User %s" % u
            print "  facebook id: %s" % usa.uid
            print "  access token: %s" % usa.extra_data['access_token']
            checkins_resp = requests.get('%s/%s/checkins?access_token=%s' %
                (FACEBOOK_GRAPH_HOST, usa.uid, usa.extra_data['access_token']))
            checkins = json.loads(checkins_resp.content)
            print checkins['data'][0]
            # look for facility matching check-in
            # check facility's latest inspection score
            # if bad score, send notification
            pass

