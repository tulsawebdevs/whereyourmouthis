import StringIO
import csv
import requests

from django.http import HttpResponse, HttpResponseBadRequest
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.views.generic import TemplateView

from inspections.forms import FacilityImportForm
from inspections.models import Facility, Load


class AppCacheTemplateView(TemplateView):
    def render_to_response(self, context, **response_kwargs):
        response_kwargs['mimetype'] = 'text/cache-manifest'
        cities = Facility.objects.values('city').distinct()
        last_load = Load.objects.latest()
        return super(TemplateView, self).render_to_response(
            {'cities': cities, 'last_load': last_load},
            **response_kwargs)

def import_facility(request):
    form = FacilityImportForm(request.POST, request.FILES)
    if request.method == "POST":
        if form.is_valid():
            form.save()
            success = True
        else:
            success = False

    context = {'form': form, 'success': success}
    return render_to_response("imported.html", context,
                              context_instance=RequestContext(request))

def region(request):
    lat = request.GET.get('lat', '')
    lng = request.GET.get('lng', '')
    if not lat or not lng:
        return HttpResponseBadRequest("lat and lng are both required ... to be spelled right.")
    boundary_url = 'http://www.oklahomadata.org/boundary/1.0/boundary/?contains=%s,%s&sets=counties'
    resp = requests.get(boundary_url % (lat, lng ))
    slug = resp.json['objects'][0]['name'].lower()
    return HttpResponse("/%s.json" % slug)

def region_json(request, region):
    facilities = Facility.objects.filter(city__iexact=region.lower())
    return render_to_response("inspections/region.json.html",
                              {'facilities': facilities},
                              mimetype='application/json')

def load(request):
    """Load documents from uploaded file."""
    form = FacilityImportForm
    if request.method == 'POST':
        # Accept the uploaded document data.
        file_data = None
        form = FacilityImportForm(request.POST, request.FILES)
        if form.is_valid():
            uploaded_file = request.FILES['file']
            if uploaded_file.multiple_chunks():
                file_data = open(uploaded_file.temporary_file_path(), 'r')
            else:
                file_data = uploaded_file.read()

        if file_data:
            f = StringIO.StringIO(file_data)
            reader = csv.DictReader(f)
            for row in reader:
                try:
                    data = {}
                    data['name'] = row['name']
                    data['address'] = row['address']
                    data['latest_score'] = row['score']
                    location = row['location']
                    parts = location.split("\n")
                    city_zip = parts[1].split(" ")
                    data['city'] = city_zip[0]
                    data['zip_code'] = city_zip[1]
                    lat_lng = parts[2].strip('()').split(", ")
                    if len(lat_lng) > 1:
                        data['latitude'] = lat_lng[0]
                        data['longitude'] = lat_lng[1]
                    facilities = Facility.objects.filter(name=data['name'],
                                                    address=data['address'])
                    facility = Facility()
                    if facilities:
                        facility = facilities[0]
                    for (key, value) in data.items():
                        setattr(facility, key, value)
                    facility.save()
                except:
                    pass
            # create a load object for the timestamp
            l = Load.objects.create()
            l.save()

    context = {'import_file_form': form, }
    return render_to_response('admin/inspections/load_data_form.html',
                              context,
                              context_instance=RequestContext(request))
