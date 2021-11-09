#configuration constants
ALLOWED_EXTENSIONS = ['fasta', 'fa']
JOBQUEUE="direct" #possible values: slurm , direct
MAILSERVER="sendgrid" #possible values: sendgrid, gmail or internal
SENDGRID_APIKEY='' #sendgrid key
SENDGRID_SENDER_EMAIL='' #sendgrid validated email address