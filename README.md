## Highlights

* Explains a bidirectional chat with chat details being saved in DynamoDB.
* Uses s3 website to broadcast message to all active users connected.
* Has connect time,disconnect time and lastest chat/broadcast message in DynamoDB.
* Refer below architecture for high level design.

## Architecture
<p align="center">
  <img src="Slide.png" width="450" height="300" title="Architecture"> 
</p>

## Steps to replicate
  
  1. Setup DynamoDB
  
     **1.1** Create Table "chatDetails" with below fields with least provisioned capacity
     
	    **i.** connectionId as String and as a Partition key
		
	    **ii.** BroadcastMessage as String
		
	    **iii.** ConnectionTime as String
		
	    **iv.** DisconnectTime as String

	    **v.** LatestBroadcasttime as String

	    **vi.** Latestmessagetime as String

	    **vii.** Message as String		
		
  2. Create Lambda functions
  
      **2.1** Create Python Lambda "WebSocketConnect" and add "AmazonDynamoDBFullAccess" managed IAM policy 
      
      **2.2** Create Python Lambda "WebSocketSendMessage" and add "AmazonDynamoDBFullAccess" and "AmazonAPIGatewayInvokeFullAccess" managed IAM policy and edit line 7 to replace below line to add websocket API gateway connection url
      	
		```bash
		client = boto3.client('apigatewaymanagementapi', endpoint_url="#Websocket_API_gateway_connection_URL#/production")
									 to be replaced to something similar to below
		client = boto3.client('apigatewaymanagementapi', endpoint_url="https://3kzyms47sk.execute-api.us-east-1.amazonaws.com/production")
		```

      **2.3** Create Python Lambda "WebSocketBroadcast" and add "AmazonDynamoDBFullAccess" and "AmazonAPIGatewayInvokeFullAccess" managed IAM policy and edit line 10 to replace below line to add websocket API gateway connection url
      
		```bash
		client = boto3.client('apigatewaymanagementapi', endpoint_url="#Websocket_API_gateway_connection_URL#/production")
									to be replaced to something similar to below
		client = boto3.client('apigatewaymanagementapi', endpoint_url="https://3kzyms47sk.execute-api.us-east-1.amazonaws.com/production")
		```
				
      **2.4** Create Python Lambda "WebSocketDisconnect" and add "AmazonDynamoDBFullAccess" managed IAM policy

  3. Create WebSocket API
  
       **3.1** Create websocket API with below details
       
		**i.** With "Route selection expression" as "request.body.action"
		
		**ii.** Click "Next" and Click "$ Add connect route","$Add disconnect route" and "'Add custom route' to be sendMessage"
		
		**iii.** Click "Next" to add "Integration type to Lambda for all three"
		
		* For "$connect" Integration choose "WebSocketConnect" ARN
		* For "$disconnect" Integration choose "WebSocketDisconnect" ARN
		* For "sendMessage" Integration choose "WebSocketSendMessage" ARN
		
		**iv.** Click "Next" to add "Stages" as "production" and "create and deploy"
		
       **3.2** Create a REST API Gateway with below details.
       
	    * Create new Resource named "broadcastmessage" and POST method and Under "Integration Request" redirect requests to "WebSocketBroadcast" lambda 
		* Enable CORS
		* Deploy API under the Deployment stage as "dev"
		
  4. Setup S3 public bucket

       **4.1** Create a public bucket with below bucket policy
	 ```bash
		{
	    "Version": "2012-10-17",
	    "Statement": [
		{
		    "Sid": "PublicRead",
		    "Effect": "Allow",
		    "Principal": "*",
		    "Action": [
			"s3:GetObject",
			"s3:GetObjectVersion"
		    ],
		    "Resource": "arn:aws:s3:::#bucketname#/*"
		}
	    ]
		}
	  ```
	
       **4.2**  Edit "Broadcast.html" and modify the below in line 41 to add API gateway connection url   
        ```bash
		fetch("#API_gateway_Connection_URL#/dev", requestOptions)"
						to be replaced to something similar to below	
		fetch("https://50opsp1bk2.execute-api.us-east-1.amazonaws.com/dev/broadcastmessage", requestOptions)
		```
		
       **4.3**  Upload "Broadcast.html" to the bucket
   
  5. Access the website

      **5.1**  Use "Broadcast.html" to broadcast message to all active users

  5. Use https://www.piesocket.com/websocket-tester and https://websocketking.com/ for testing.
  6. Use {"action":"sendMessage","Message":"hi"} for sending message to server
      

## Youtube references

<!-- YOUTUBE:START -->
- [Websocket setup](https://www.youtube.com/watch?v=FIrzkt7kH80&t=37s)
- [Upload connection details to DynamoDB](https://www.youtube.com/watch?v=n5XFPLo4Bbw&t=2692s)
<!-- YOUTUBE:END -->


<!-- 1. item1
1. item2
    1. subitem1
    2. subitem2 -->

