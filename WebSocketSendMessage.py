import json
import urllib3
import boto3
from botocore.exceptions import ClientError
from time import gmtime, strftime

client = boto3.client('apigatewaymanagementapi', endpoint_url="Websocket API gateway connection URL/production")
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('chatDetails')

def lambda_handler(event, context):
    try:
        print(event)
        
        #Extract connectionId from incoming event
        connectionId1 = event["requestContext"]["connectionId"]
        now = strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())
        
        #Convert string to dictionary
        message=json.loads(event["body"])["Message"]
        response = table.update_item(
            Key={
                'connectionId': connectionId1
            },
            ExpressionAttributeNames={
                '#L': 'Latestmessagetime',
                '#M': 'Message'
            },
            ExpressionAttributeValues={
                ':l':  now,
                ':m':  message

            },
            UpdateExpression='SET #L = :l, #M = :m',
            ReturnValues="UPDATED_NEW"
        )
        responseMessage = "Responding back from the Websocket Service after updating details in DB"
        
        #Form response and post back to connectionId
        response1 = client.post_to_connection(ConnectionId=connectionId1, Data=json.dumps(responseMessage).encode('utf-8'))
        
    except ClientError as e:
        print(e.response['Error']['Message'])
    return { "statusCode": 200  }