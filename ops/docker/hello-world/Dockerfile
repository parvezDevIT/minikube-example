# Use a modern, secure, and actively maintained base image
FROM python:3.12-slim-bookworm

# Combine apt-get update and install to avoid layer caching issues
# Clean up cache files right away to dramatically reduce final image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-wsgi-py3 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker's build cache safely
WORKDIR /var/www/flaskapp
COPY app/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy flask application code
COPY app/src/ /var/www/flaskapp/

# Configure Apache (Enable modules and virtual hosts)
COPY config/apache/flaskapp.conf /etc/apache2/sites-available/flaskapp.conf
RUN a2enmod wsgi && a2ensite flaskapp

# Copy over the WSGI configuration file
COPY config/wsgi/flaskapp.wsgi /var/www/flaskapp/flaskapp.wsgi

# Set system configurations safely without touching interactive shell limits
ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2

# Expose standard web traffic port
EXPOSE 80

# Launch Apache in the foreground directly as the entry container process
CMD ["apachectl", "-DFOREGROUND"]
