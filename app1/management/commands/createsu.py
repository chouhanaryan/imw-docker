from django.core.management.base import BaseCommand
from app1.models import User


class Command(BaseCommand):
    def handle(self, *args, **options):
        if not User.objects.filter(email="admin@admin.com").exists():
            User.objects.create_superuser(
                first_name="admin",
                last_name="admin",
                age=1,
                gender="M",
                email="admin@admin.com",
                password="admin",
            )
