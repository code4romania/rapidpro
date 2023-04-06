#!/command/with-contenv sh

cd /var/www

echo "Checking..."
python3 manage.py check

if [ "${RUN_MIGRATION}" = "yes" ]; then
    echo "Migrating databse"
    python3 manage.py migrate --run-syncdb
fi

if [ "${RUN_IMPORT_GEOJSON}" = "yes" ]; then
    echo "Importing geojson"
    python3 manage.py import_geojson $(ls /opt/geojson/**/*.json)
fi

# if [ "${RUN_COMPILE_MESSAGES}" = "yes" ]; then
#     echo "Compiling translation messages"
#     python3 manage.py compilemessages
# fi

if [ "${RUN_COLLECT_STATIC}" = "yes" ]; then
    echo "Collect static"
    mkdir -p /var/www/sitestatic
    python3 manage.py collectstatic --noinput
fi

if [ "${RUN_CREATE_SUPER_USER}" = "yes" ]; then
    echo "Create superuser"
    python3 manage.py createsuperuser --noinput \
        --username "${DJANGO_ADMIN_USERNAME}" --email "${DJANGO_ADMIN_EMAIL}"

    echo "Set superuser password"
    python3 manage.py shell -c "from django.contrib.auth.models import User; u = User.objects.get(username=\"${DJANGO_ADMIN_USERNAME}\"); u.set_password(\"${DJANGO_ADMIN_PASSWORD}\"); u.save()"
fi
