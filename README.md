![Heroku](https://pyheroku-badge.herokuapp.com/?app=sistr-app&style=flat)
# SISTR web-app repository
This repository provides an **easy** deployable web application wrapper for the SISTR tool.

##### Demo SISTR web-app
For demo purposes, a test version of this SISTR web-app running SISTR version 1.1.1 is also available at [https://sistr-app.herokuapp.com/](https://sistr-app.herokuapp.com/)

**NOTE:** The Heroku web application might take up to 20 seconds to load on the first run and all submitted information is temporary stored for 30 min.


## Deployment options
1. Locally as a:
    - Docker container: build image and deploy on local infrastructure
    - Natively on a classical web-server: install all dependencies and deploy on dedicated hosting
2. Remotely using
    - Free Heroku Platform as a Service (PaaS): Deploy publicly on free web-hosting for testing, demo or lightweight usage
    - Cloud infrastructure: Deploy publicly or privately in Cloud Virtual Machine

## Requirements
- python >= 3
- flask
- Python libraries
    - maxminddb (for optional usage monitoring)
    - pandas
    - sistr_cmd
    - sendgrid
- uWSGI (application web-server)    
- SISTR v. 1.1.1  
- [SISTR dependencies](https://github.com/phac-nml/sistr_cmd#dependencies)    
    
    
## Features
- Flask Python web framework running on the production `uwsgi` web server
- Workload job queue management allowing for concurrent job executions without server overload
- Easy deployment inside a container on local and remote settings with minimal or no configuration required
- Job completion notification via email with attached results
- Job queue monitoring via app for all submitted jobs
- Optional job queue management via SLURM or simple built-in Bash function
- Job submission history for easier results retrieval


## Configuration of web-app constants
The `constants.py` file contains on job queue and email notifications options.

- ALLOWED_EXTENSIONS controls the input file extensions which should be Salmonella genomes in FASTA format. The default values are `fasta` and `fa`
- JOBQUEUE allows to specify SLURM or simple bash script based job queue specified by `slurm` and `direct` values.
- MAILSERVER defines the mail notification method for email notification and results delivery. 
The `internal` value will use the `postfix` internal SMTP server but requires open port 25.
`sendgrid` value uses the SendGrid email messaging API to send emails but requires email registration and valid API token, `gmail` uses Gmail SMTP server to send email
- SENDGRID_APIKEY is the SendGrid API token with free accounts allowing for 1000 emails per day
- SENDGRID_SENDER_EMAIL is a validated email address to be used by SendGrid to identify the sender

## SendGrid email notification configuration
`SendGrid` allows to easily send email notifications via API after email validation. 
Obtain a SendGrid account, register email dedicated for email notifications, generate a custom token,
update `SENDGRID_APIKEY` and `SENDGRID_SENDER_EMAIL` values. The free tier allows for 1000 notifications per day.

## Gmail email notification configuration
As a second option, email notifications could be sent via existing Gmail account. 
In `constants.py set` set `MAILSERVER` constant to `gmail` value and provide email login details in `static/python_utils/send_gmail_notification.py`.
Please modify the `gmail_user` and `gmail_password` values or import them as environmental variables `os.environ.get('VAR_NAME')`.
This could be a nice option if SMTP port 25 is blocked by an ISP. 

## SLURM deployment (requires root access)
The configuration file is located at `aux/SLURM/slurm.conf` and could be customized. 
The default configuration assumes the hostname is `sistr-dev`. Change the file accordingly to your context. If the hostname is different, SLURM would not run.
The `supervisor` launches `/usr/sbin/slurmctld`, `/usr/sbin/slurmd` and `/usr/sbin/munged` required for SLURM to run.
Finally, SLURM requires creation of series of directories specified in the `Dockerfile` under the SLURM section.

If you have difficulty deploying SLURM, use internal Bash queue management requiring no install.

## Deployment via a custom Docker image compilation and customization
Using a `Dockerfile` it is very easy to deploy a web-app in any context thanks to
the ease of the Docker image deployment thanks to minimal configuration requirements. This is the recommended deployment strategy

Simply customize the Dockerfile and build the default image:
```
docker build -f Dockerfile . -t sistr-server-dev:latest
```

Alternatively build a custom "lighter" image for Herou service (for a faster boot):
```
docker build -f Dockerfile.heroku . -t sistr-server-dev:latest
```

To run the web-app Docker image on say port 5010:
```
docker run -it --rm -h sistr-dev -p 5010:5010  -v  `pwd`:/mnt sistr-server-dev:latest
```

## Deployment on a Heroku server as a Docker image
Heroku is a wonderful free server allowing to publicly deploy Docker images as web containers (Dynos). 
The free tier assigned a VM with 512 MB RAM, 1 CPU and 30 GB of space with 550 working hours/month which is more than enough for light use.
The VM with Docker image is booted on demand and automatically shuts down after 30 min of inactivity saving the monthly active hours allowance. 

To deploy sist-web-app image on Heroku follow the following steps:
1. Sign up with Heroku service at 
1. Install the Heroku CLI as per [https://devcenter.heroku.com/articles/heroku-cli](https://devcenter.heroku.com/articles/heroku-cli) to control web-app via CLI
1. Create app slot and name your web app (E.g. `sistr-app`)
    ```bash
    heroku login
    APP_NAME="sistr-app"
    heroku create ${APP_NAME}
   ```
1. Build and release the lighter image for Heroku from the `Dockerfile.heroku` file and tag it according to `registry.heroku.com/<app_name>/web` formula
    ```bash
    APP_NAME="sistr-app"
    docker build -f Dockerfile.heroku . -t  registry.heroku.com/${APP_NAME}/web
    
    heroku container:login
    docker push registry.heroku.com/${APP_NAME}/web
    heroku container:release web -a ${APP_NAME}
        
    ```
1. Alternatively, in terminal issue the following commands to build and release Docker container from the `Dockerfile`
    ```bash
    heroku container:login
    heroku container:push web -a ${APP_NAME}
    heroku container:release web -a ${APP_NAME}
    ```
1. At `https://dashboard.heroku.com/apps` check status of app and logs. The app should be accessible via `<app_name>.hherokuapp.com` URL
1. To connect to the VM shell run `heroku run bash -a ${APP_NAME}`

## Local native deployment on a dedictated private server
1. Access a dedicated machine running any Linux distribution (e.g. Ubuntu)
1. Copy source code and install dependencies
1. Configure application by editing `constants.py` file and selecting the desired job queue management (SLURM or launch BASH script `static/bash_templates/launch_template.sh`)
1. Launch background services as required (SLURM, email server) via `/usr/bin/supervisord -c /etc/supervisord.conf` command
1. Launch web-app code via `uwsgi` on the desired open port (`uwsgi --ini uwsgi.ini --http-socket :<port>`) or, 
for testing purposes, launch using the Flask development web server `flask run --host=0.0.0.0 --port=<port>`. For `flask run` optionally define `FLASK_APP` global variable to point to the `app.py` file.



## Citation
[The *Salmonella In Silico* Typing Resource (SISTR): an open web-accessible tool for rapidly typing and subtyping draft *Salmonella* genome assemblies. Catherine Yoshida, Peter Kruczkiewicz, Chad R. Laing, Erika J. Lingohr, Victor P.J. Gannon, John H.E. Nash, Eduardo N. Taboada. PLoS ONE 11(1): e0147101. doi: 10.1371/journal.pone.0147101](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0147101)


## Created by
- [Kyrylo Bessonov](https://github.com/kbessonov1984/)

## License
Copyright 2020 Public Health Agency of Canada
Distributed under the Apache 2.0 license.