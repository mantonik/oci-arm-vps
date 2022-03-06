#!/bin/bash

sudo snap install core; sudo snap refresh core


pip install certbot



602  python3 -m venv /opt/certbot/
  603  /opt/certbot/bin/pip install --upgrade pip
  604  /opt/certbot/bin/pip install certbot certbot-nginx
  605  /opt/certbot/bin/pip install certbot certbot-nginx --global http.sslVerify false
  606  /opt/certbot/bin/pip install --trusted-host pypi.org certbot certbot-nginx 
  607  /opt/certbot/bin/pip install --trusted-host pypi.org certbot certbot-nginx 
  609  /opt/certbot/bin/pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org certbot certbot-nginx 
  625  sudo python3 -m venv /opt/certbot/
  626  /opt/certbot/bin/pip install --upgrade pip
  627  /opt/certbot/bin/pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --upgrade pip
  629  /opt/certbot/bin/pip  install --upgrade --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org pip
  630  /opt/certbot/bin/pip3  install --upgrade --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org pip
  631  vi /opt/certbot/bin/pip3  install --upgrade --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org pip
  699  /opt/certbot/bin/pip install -- update --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org  pip
  700  /opt/certbot/bin/pip install --update --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org  pip
  701  /opt/certbot/bin/pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org  --upgrade pip
  702  /opt/certbot/bin/pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org  --upgrade pip -VVCtVgPPIY1n5vWwTsEfMtXEGaVVoOUftZgu
  703  /opt/certbot/bin/pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org  --upgrade pip -vv
  710  /opt/certbot/bin/pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org  --upgrade pip -vv
  711  /opt/certbot/bin/pip install --update pip
  712  /opt/certbot/bin/pip install --update pip
  713  /opt/certbot/bin/pip install certbot certbot-nginx
  714   ln -s /opt/certbot/bin/certbot /usr/bin/certbot
  715  certbot --nginx
  993  history |grep certbot


