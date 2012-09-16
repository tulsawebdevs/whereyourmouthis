from django.shortcuts import render_to_response
from django.template import RequestContext

from inspections.forms import FacilityImportForm

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
            pass
            """
            # Try to import the data, but report any error that occurs.
            try:
                counter = Document.objects.load_json(request.user, file_data)
                user_msg = (_('%(obj_count)d object(s) loaded.') %
                            {'obj_count': counter, })
                messages.add_message(request, messages.INFO, user_msg)
            except Exception, e:
                err_msg = (_('Failed to import data: %(error)s') %
                           {'error': '%s' % e, })
                messages.add_message(request, messages.ERROR, err_msg)
            """

    context = {'import_file_form': form, }
    return render_to_response('admin/inspections/load_data_form.html',
                              context,
                              context_instance=RequestContext(request))
