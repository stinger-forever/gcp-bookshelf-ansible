#!/usr/bin/env bash

# Python environment setup
sudo virtualenv -p python3 /opt/app/gce/env
source /opt/app/gce/env/bin/activate
/opt/app/gce/env/bin/pip install -r /opt/app/gce/requirements.txt

# Set ownership to newly created account
sudo chown -R pythonapp:pythonapp /opt/app

# Put supervisor configuration in proper place
sudo cp /opt/app/gce/python-app.conf /etc/supervisor/conf.d/python-app.conf

sudo wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy
sudo chmod +x /usr/local/bin/cloud_sql_proxy

sudo cloud_sql_proxy -instances=osdu-deploy-gasparyan:europe-west1:bookshelf-dbase=tcp:3306

sudo echo "
[Unit]
Description=Connecting MySQL Client from Compute Engine using the Cloud SQL Proxy
Documentation=https://cloud.google.com/sql/docs/mysql/connect-compute-engine
Requires=networking.service
After=networking.service

[Service]
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/cloud_sql_proxy -dir=/var/run/cloud-sql-proxy -instances=osdu-deploy-gasparyan:europe-west1:bookshelf-dbase=tcp:3306
Restart=always
StandardOutput=journal
User=root

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/cloud-sql-proxy.service

#wget -O /opt/app/config.py https://github.com/GoogleCloudPlatform/getting-started-python/blob/steps/7-gce/config.py



# Start service via supervisorctl
sudo supervisorctl reread
sudo supervisorctl update

exit 0
