import StringIO
import csv

from django.shortcuts import render_to_response
from django.template import RequestContext

from inspections.forms import FacilityImportForm
from inspections.models import Facility

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

    context = {'import_file_form': form, }
    return render_to_response('admin/inspections/load_data_form.html',
                              context,
                              context_instance=RequestContext(request))
