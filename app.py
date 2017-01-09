from flask import Flask, request
from twilio.rest import TwilioRestClient

app = Flask(__name__)
 
# put your own credentials here 
ACCOUNT_SID = 'AC358a60437a112c5c59d3b52da1f0dcc7' 
AUTH_TOKEN = 'e7ae1b711f733bae6c2647bd62154b77' 
 
client = TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN)
 
@app.route('/sms', methods=['GET'])
def send_sms():
    message = client.messages.create(
        to=request.args['To'], 
        from_= '+16504378740', 
        body=request.args['Body'],
    )
    return message.sid

if __name__ == '__main__':
        app.run()
