import json
import urllib3
import boto3
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Attr
from time import gmtime, strftime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('chatDetails')	
client = boto3.client('apigatewaymanagementapi', endpoint_url="Websocket_API_gateway_connection_URL/production")

def lambda_handler(event, context):
    try:
        response=table.scan(FilterExpression=Attr('DisconnectTime').eq('Session Active'))
        data = response['Items']
        now = strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())
        for listdata in data:
            #print (listdata.get('connectionId'))
            connectionId=listdata.get('connectionId')
            message = event["Message"]
            response1 = table.update_item(
            Key={
                'connectionId': connectionId
            },
            ExpressionAttributeNames={
                '#L': 'LatestBroadcasttime',
                '#M': 'BroadcastMessage'
            },
            ExpressionAttributeValues={
                ':l':  now,
                ':m':  message

            },
            UpdateExpression='SET #L = :l, #M = :m',
            ReturnValues="UPDATED_NEW"
            )
            response = client.post_to_connection(ConnectionId=connectionId, Data=json.dumps(message).encode('utf-8'))
            print(response)
            
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return { "statusCode": 200  }
		