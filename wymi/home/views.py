from django.views.generic import TemplateView

class HomeIndexView(TemplateView):
    template_name = "home/index.html"
