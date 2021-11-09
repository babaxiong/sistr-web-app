import sendgrid
from sendgrid.helpers.mail import Mail, Attachment,FileContent,FileName,FileType,Disposition
import base64
import argparse
import os
import pandas as pd

def arguments():


    parser = argparse.ArgumentParser(
        description="Send Gmail notification simple utility")
    parser.add_argument('-e',
                        default='',
                        help='Email of a recipient')
    parser.add_argument('-f',
                        default='',
                        help='Email of a sender (validated by SendGrid)')

    parser.add_argument('-t',
                        default='',
                        help='Job token')
    parser.add_argument('-b',
                        default='/',
                        type=str,
                        required=True,
                        help='Base directory of the web-app')
    parser.add_argument('-a',
                        type=str,
                        help='SendGrid API key')

    args = parser.parse_args()

    return args

args = arguments()
if args.e and args.t:
    print(args.a)
    sg = sendgrid.SendGridAPIClient(api_key=args.a)
    #sg = sendgrid.SendGridAPIClient(api_key=os.environ.get('SENDGRID_API_KEY'))


    message = Mail(
        from_email=args.f,
        to_emails=args.e,
        subject='SISTR: Your job {} is ready'.format(args.t),
        html_content="<p>Dear user,</p><p>Your serotyping results for token {} are ready and are attached.</p></p>SISTR TEAM</p>".format(args.t))

    results_dir=os.path.join(args.b,"results",args.t)
    #csv_results_files_list = [file for file in os.listdir(results_dir) if file.endswith("csv") ]
    results_concat_outfile_path=os.path.join(results_dir,"SISTR_results_token_{}.tsv".format(args.t))


    #if csv_results_files_list and len(csv_results_files_list) > 1:
    #    df = pd.concat((pd.read_csv(os.path.join(results_dir,file), header=0)
    #                    for file in csv_results_files_list))
    #    df.to_csv(results_concat_outfile_path,index=False)


    with open(results_concat_outfile_path, 'rb') as f:
        data = f.read()
        f.close()
    encoded_file = base64.b64encode(data).decode()

    attachedFile = Attachment(
        FileContent(encoded_file),
        FileName("SISTR_results_token_{}.tsv".format(args.t)),
        FileType('text/plain'),
        Disposition('attachment')
    )
    print(message.attachment)
    message.attachment = attachedFile

    try:
        #sg = SendGridAPIClient(os.environ.get('SENDGRID_API_KEY'))
        response = sg.send(message)
        print(response.status_code)
        print(response.body)
        print(response.headers)
    except Exception as e:
        print(e)

else:
    raise ("Email or Token not defined. Their values were email:{} and token:{}".format(args.e, args.t))