import boto3
from time import gmtime, strftime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('chatDetails')

def lambda_handler(event, context):
    print(event)
    connectionid1 = event["requestContext"]["connectionId"]
    now = strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())
    response = table.put_item(
        Item={
            'connectionId' : connectionid1,
            'ConnectionTime' : now ,
            'DisconnectTime' : "Session Active"
            })
    return {'statusCode': 200}