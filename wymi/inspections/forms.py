import csv

from django import forms

from inspections.models import Facility

class FacilityImportForm(forms.Form):
    file = forms.FileField()

    def save(self, commit=False, *args, **kwargs):
        records = csv.reader(self.cleaned_data["file"])
        for line in records:
            f = Facility()
            f.id = line[0]
            f.type = line[2]
            f.name = line[3]
            f.address = line[4]
            f.latitude = line[5]
            f.longitude = line[6]
            f.save()
