#! /usr/bin/python3
import smtplib, argparse

def arguments():


    parser = argparse.ArgumentParser(
        description="Send Gmail notification simple utility")
    parser.add_argument('-e',
                        default='',
                        nargs='+',
                        help='Email(s) of a recipient')

    parser.add_argument('-t',
                        default='',
                        help='Job token')


    args = parser.parse_args()

    return args

sent_from_gmail = ''
gmail_password = ''
SISTR_URL=''

def compose_email(token, send_to):
    sent_from_gmail
    subject = 'SISTR: Your job {} is ready'.format(token)
    body = 'Dear user,\nPlease download your results from {} using token {}\n\nSincerely,\nSISTR TEAM'.format(SISTR_URL, token)

    email_text = """From: %s\nTo: %s\nSubject: %s\n\n%s""" % (
        sent_from_gmail,
           ", ".join(send_to),
           subject,
           body
    )

    return sent_from_gmail, send_to, email_text

try:
    args = arguments()
    print(args);exit(1)

    if args.e and args.t:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.ehlo()
        server.starttls()
        server.login(sent_from_gmail, gmail_password)

        sent_from, sent_to, email_text = compose_email(args.t, args.e)
        server.sendmail(sent_from, sent_to, email_text)
        server.close()

        print ('Email successfully sent!')
    else:
        raise("Email or Token not defined. Their values were email:{} and token:{}".format(args.e, args.t))
except Exception as e:
    print ('Something went wrong... {}'.format(e))