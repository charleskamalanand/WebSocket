import boto3
from botocore.exceptions import ClientError
from time import gmtime, strftime
	
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('chatDetails')	
	
def lambda_handler(event, context):
    try:
        connectionid1 = event["requestContext"]["connectionId"]
        now = strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())
        response = table.update_item(
            Key={
                'connectionId': connectionid1#,
                #'DisconnectTime' : "Active"
            },
            ExpressionAttributeNames={
                '#D': 'DisconnectTime'
            },
            ExpressionAttributeValues={
                ':d':  now

            },
            UpdateExpression='SET #D = :d',
            ReturnValues="UPDATED_NEW"
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
    return { "statusCode": 200  }