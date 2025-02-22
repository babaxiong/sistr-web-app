FROM ubuntu:20.04
ENV DEBIAN_FRONTEND="noninteractive" TZ="America/New_York"
ENV FLASK_APP="/app/app.py"
RUN apt update && apt install vim tzdata python3 python3-pip  python3-pycurl -y 
RUN pip3 install flask maxminddb pandas==1.0.5 sistr_cmd==1.1.1  
RUN pip3 install uwsgi
RUN apt -y install gcc g++ make  libmunge-dev bzip2 vim tar wget

#Optional
RUN apt -y install openssh-server munge git supervisor
RUN apt -y install slurmd slurm-client slurmctld
RUN apt -y install mailutils

COPY aux/SLURM/slurm.conf /etc/slurm/
COPY aux/SLURM/supervisord.conf /etc/supervisord.conf

COPY app.py  /app/
COPY constants.py  /app/
COPY uwsgi.ini  /app/
ADD static /app/static
ADD templates /app/templates

#SLURM
RUN mkdir -p /var/log/slurm && touch /var/log/slurm/job_completions  /var/log/slurm/accounting
RUN chown -R slurm:slurm /var/log/slurm
RUN mkdir -p /var/spool/node_state /var/spool/job_state
RUN chown -R  root:slurm /var/spool && chmod a+w /var/spool
RUN chown -R root:root /var/log/munge /var/lib/munge
RUN mkdir -p /var/run/munge && chown -R root:root /var/run/munge /etc/munge /run/munge /var/log/munge/


# FOR SISTR
RUN apt -y install ncbi-blast++ mafft libcurl4-openssl-dev libssl-dev mash

# Install SendGrid for notification messages
RUN pip3 install sendgrid

# Messages
# RUN echo "echo 'Log files located at /var/log/supervisor/'"  >> /root/.bashrc


#LAUNCH upon startup
CMD /usr/bin/supervisord -c /etc/supervisord.conf  && cd /app && uwsgi --ini uwsgi.ini --http-socket :5010
#CMD  cd /app && uwsgi --ini uwsgi.ini --http-socket :$PORT

# flask run --host=0.0.0.0 --port=$PORT
#docker build . -t sistr-server-dev:latest
#
#/usr/bin/supervisord -c /etc/supervisord.conf -s  &
#docker run -it --rm -h sistr-dev -p 5010:5010  -v  `pwd`:/mnt sistr-server-dev:latest  
#nohup python3 /mnt/app.py  > log.txt 2>&1
