import datetime
import json
from urllib import urlencode
import requests

from django.core.management.base import BaseCommand
from social_auth.models import UserSocialAuth


FACEBOOK_GRAPH_HOST = 'https://graph.facebook.com'

class Command(BaseCommand):
    help = "Create notifications for users."

    def handle(self, *args, **kwargs):
        # TODO: refactor into a FBQL query like
        # /fql?q=SELECT uid from checkin where author_uid in [x for x in usa.objects.all()['id']] and timestamp > 5 mins ago
        for usa in UserSocialAuth.objects.all():
            u = usa.user
            print "User %s" % u
            print "  facebook id: %s" % usa.uid
            print "  access token: %s" % usa.extra_data['access_token']
            urlparams_dict = {
                'access_token': usa.extra_data['access_token'],
                'since': datetime.datetime.today() - datetime.timedelta(minutes=-5),
            }
            checkins_resp = requests.get('%s/%s/checkins?%s' %
                (FACEBOOK_GRAPH_HOST, usa.uid, urlencode(urlparams_dict)))
            checkins = json.loads(checkins_resp.content)
            if checkins['data']:
                print checkins['data'][0]
            # look for facility matching check-in
            # check facility's latest inspection score
            # if bad score, send notification
            pass

