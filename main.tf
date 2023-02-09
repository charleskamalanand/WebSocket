provider "aws" {
  region = "us-east-2"
}

variable "All_Variables" {
  type    = list(string)
  default = ["us-east-2", "951560400874", "Dev", "Deployed from terraform"]
}

data "archive_file" "lambda1-zip" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda.zip"
}


resource "aws_dynamodb_table" "chatDetails" {
  name             = "chatDetails"
  hash_key         = "connectionId"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "connectionId"
    type = "S"
  }

  tags = {
    Name = var.All_Variables[3]
  }
}

#WebSocketConnect
resource "aws_iam_role" "WebSocketConnect_lambda_Role" {
  name = "WebSocketConnect_lambda_Role_Terraform"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = var.All_Variables[3]
  }
}
resource "aws_iam_role_policy_attachment" "WebSocketConnect_Policy_Attachment" {
  role       = aws_iam_role.WebSocketConnect_lambda_Role.name
  policy_arn = aws_iam_policy.WebSocketConnect_LambdaPolicy.arn
}

resource "aws_iam_policy" "WebSocketConnect_LambdaPolicy" {
  name        = "WebSocketConnect_LambdaPolicy_Terraform"
  path        = "/"
  description = "IAM policy for logging from a lambda and for put item to DynamoDB"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          #"Resource": "arn:aws:logs:us-east-2:9**********4:*"
          "Resource" : join(":*", [join(":", [join("", ["arn:aws:logs:", var.All_Variables[0]]), var.All_Variables[1]]), ""]),          
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : "dynamodb:putItem",
          #"Resource": "arn:aws:dynamodb:us-east-2:9**********4:table/ProductVisits/stream/*"
          "Resource" : join(":table/", [join(":", [join("", ["arn:aws:dynamodb:", var.All_Variables[0]]), var.All_Variables[1]]), aws_dynamodb_table.chatDetails.name])
        }
      ]
  })
  tags = {
    Name = var.All_Variables[3]
  }
}


resource "aws_lambda_function" "WebSocketConnect" {
  filename      = "lambda.zip"
  function_name = "WebSocketConnect"
  role          = aws_iam_role.WebSocketConnect_lambda_Role.arn
  handler       = "WebSocketConnect.lambda_handler"
  runtime       = "python3.9"
  tags = {
    Name = var.All_Variables[3]
  }
}

resource "aws_lambda_permission" "Lambda_Permission_WebSocketConnect" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.WebSocketConnect.function_name
  principal     = "apigateway.amazonaws.com"
  #api_endpoint    = "${aws_apigatewayv2_api.chatMachine.api_endpoint}"
}

#WebSocketDisconnect

resource "aws_iam_role" "WebSocketDisconnect_lambda_Role" {
  name = "WebSocketDisconnect_lambda_Role_Terraform"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = var.All_Variables[3]
  }
}
resource "aws_iam_role_policy_attachment" "WebSocketDisconnect_Policy_Attachment" {
  role       = aws_iam_role.WebSocketDisconnect_lambda_Role.name
  policy_arn = aws_iam_policy.WebSocketDisconnect_LambdaPolicy.arn
}

resource "aws_iam_policy" "WebSocketDisconnect_LambdaPolicy" {
  name        = "WebSocketDisconnect_LambdaPolicy_Terraform"
  path        = "/"
  description = "IAM policy for logging from a lambda and for delete item to DynamoDB"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          #"Resource": "arn:aws:logs:us-east-2:9**********4:*"
          "Resource" : join(":*", [join(":", [join("", ["arn:aws:logs:", var.All_Variables[0]]), var.All_Variables[1]]), ""]),          
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : ["dynamodb:DeleteItem","dynamodb:UpdateItem"],
          #"Resource": "arn:aws:dynamodb:us-east-2:9**********4:table/ProductVisits/stream/*"
          "Resource" : join(":table/", [join(":", [join("", ["arn:aws:dynamodb:", var.All_Variables[0]]), var.All_Variables[1]]), aws_dynamodb_table.chatDetails.name])
        }
      ]
  })
  tags = {
    Name = var.All_Variables[3]
  }
}


resource "aws_lambda_function" "WebSocketDisconnect" {
  filename      = "lambda.zip"
  function_name = "WebSocketDisConnect"
  role          = aws_iam_role.WebSocketDisconnect_lambda_Role.arn
  handler       = "WebSocketDisconnect.lambda_handler"
  runtime       = "python3.9"
  tags = {
    Name = var.All_Variables[3]
  }
}

resource "aws_lambda_permission" "Lambda_Permission_WebSocketDisconnect" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.WebSocketDisconnect.function_name
  principal     = "apigateway.amazonaws.com"
  #api_endpoint    = "${aws_apigatewayv2_api.chatMachine.api_endpoint}"
}


resource "aws_iam_role" "WebSocketSendMessage_lambda_Role" {
  name = "WebSocketSendMessage_lambda_Role_Terraform"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = var.All_Variables[3]
  }
}
resource "aws_iam_role_policy_attachment" "WebSocketSendMessage_Policy_Attachment" {
  role       = aws_iam_role.WebSocketSendMessage_lambda_Role.name
  policy_arn = aws_iam_policy.WebSocketSendMessage_LambdaPolicy.arn
}

resource "aws_iam_policy" "WebSocketSendMessage_LambdaPolicy" {
  name        = "WebSocketSendMessage_LambdaPolicy_Terraform"
  path        = "/"
  description = "IAM policy for logging from a lambda and for delete item to DynamoDB"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          #"Resource": "arn:aws:logs:us-east-2:9**********4:*"
          "Resource" : join(":*", [join(":", [join("", ["arn:aws:logs:", var.All_Variables[0]]), var.All_Variables[1]]), ""]),          
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : ["dynamodb:DeleteItem","dynamodb:UpdateItem"],
          #"Resource": "arn:aws:dynamodb:us-east-2:9**********4:table/ProductVisits/stream/*"
          "Resource" : join(":table/", [join(":", [join("", ["arn:aws:dynamodb:", var.All_Variables[0]]), var.All_Variables[1]]), aws_dynamodb_table.chatDetails.name])
        },
        {
          "Effect" : "Allow",
          "Action" : ["execute-api:Invoke","execute-api:ManageConnections"],
          #"Resource": "arn:aws:dynamodb:us-east-2:9**********4:table/ProductVisits/stream/*"
          "Resource": "arn:aws:execute-api:*:*:*"
        }
      ]
  })
  tags = {
    Name = var.All_Variables[3]
  }
}


resource "aws_lambda_function" "WebSocketSendMessage" {
  filename      = "lambda.zip"
  function_name = "WebSocketSendMessage"
  role          = aws_iam_role.WebSocketSendMessage_lambda_Role.arn
  handler       = "WebSocketSendMessage.lambda_handler"
  runtime       = "python3.9"
  tags = {
    Name = var.All_Variables[3]
  }
}

resource "aws_lambda_permission" "Lambda_Permission_WebSocketSendMessage" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.WebSocketSendMessage.function_name
  principal     = "apigateway.amazonaws.com"
  #api_endpoint    = "${aws_apigatewayv2_api.chatMachine.api_endpoint}"
}






resource "aws_lambda_function" "WebSocketBroadcast" {
  filename      = "lambda.zip"
  function_name = "WebSocketBroadcast"
  role          = aws_iam_role.WebSocketBroadcast_lambda_Role.arn
  handler       = "WebSocketBroadcast.lambda_handler"
  runtime       = "python3.9"
  tags = {
    Name = var.All_Variables[3]
  }
}

resource "aws_lambda_permission" "Lambda_Permission_WebSocketBroadcast" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.WebSocketBroadcast.function_name
  principal     = "apigateway.amazonaws.com"
  #api_endpoint    = "${aws_apigatewayv2_api.chatMachine.api_endpoint}"
}


resource "aws_iam_role" "WebSocketBroadcast_lambda_Role" {
  name = "WebSocketBroadcast_lambda_Role_Terraform"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = var.All_Variables[3]
  }
}

resource "aws_iam_role_policy_attachment" "WebSocketBroadcast_Policy_Attachment" {
  role       = aws_iam_role.WebSocketBroadcast_lambda_Role.name
  policy_arn = aws_iam_policy.WebSocketBroadcast_LambdaPolicy.arn
}

resource "aws_iam_policy" "WebSocketBroadcast_LambdaPolicy" {
  name        = "WebSocketBroadcast_LambdaPolicy_Terraform"
  path        = "/"
  description = "IAM policy for logging from a lambda and for delete item to DynamoDB"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          #"Resource": "arn:aws:logs:us-east-2:9**********4:*"
          "Resource" : join(":*", [join(":", [join("", ["arn:aws:logs:", var.All_Variables[0]]), var.All_Variables[1]]), ""]),          
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : ["dynamodb:GetItem","dynamodb:Scan","dynamodb:UpdateItem"],
          #"Resource": "arn:aws:dynamodb:us-east-2:9**********4:table/ProductVisits/stream/*"
          "Resource" : join(":table/", [join(":", [join("", ["arn:aws:dynamodb:", var.All_Variables[0]]), var.All_Variables[1]]), aws_dynamodb_table.chatDetails.name])
        },
        {
          "Effect" : "Allow",
          "Action" : ["execute-api:Invoke","execute-api:ManageConnections"],
          #"Resource": "arn:aws:dynamodb:us-east-2:9**********4:table/ProductVisits/stream/*"
          "Resource": "arn:aws:execute-api:*:*:*"
        }
      ]
  })
  tags = {
    Name = var.All_Variables[3]
  }
}


resource "aws_apigatewayv2_api" "chatMachine" {
  name          = "chatMachine"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
  tags = {
    Name = var.All_Variables[3]
  }
}


resource "aws_apigatewayv2_integration" "chatMachine_Integration" {
  api_id               = aws_apigatewayv2_api.chatMachine.id
  integration_type     = "AWS_PROXY"
  integration_uri      = aws_lambda_function.WebSocketConnect.invoke_arn
}


resource "aws_apigatewayv2_route" "API_Route_chat" {
  api_id    = aws_apigatewayv2_api.chatMachine.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.chatMachine_Integration.id}"
}

resource "aws_apigatewayv2_stage" "API_Stage_chat" {
  api_id      = aws_apigatewayv2_api.chatMachine.id
  name        = var.All_Variables[2]
  deployment_id = aws_apigatewayv2_deployment.Deployment.id
  depends_on = [
    aws_lambda_function.WebSocketSendMessage
  ]
}

resource "aws_apigatewayv2_deployment" "Deployment" {
  api_id = aws_apigatewayv2_api.chatMachine.id

  depends_on = [
    aws_apigatewayv2_route.API_Route_chat
  ]
}

resource "aws_apigatewayv2_integration" "chatMachine_Disconnect" {
  api_id             = aws_apigatewayv2_api.chatMachine.id
  integration_type   = "AWS_PROXY"
  description        = "Disconnect Integration"
  integration_uri    = aws_lambda_function.WebSocketDisconnect.invoke_arn
}

resource "aws_apigatewayv2_route" "DisconnectRoute" {
  api_id         = aws_apigatewayv2_api.chatMachine.id
  route_key      = "$disconnect"
  operation_name = "DisconnectRoute"
  target         = "integrations/${aws_apigatewayv2_integration.chatMachine_Disconnect.id}"
}


resource "aws_apigatewayv2_integration" "SendMessageInt" {
  api_id             = aws_apigatewayv2_api.chatMachine.id
  integration_type   = "AWS_PROXY"
  description        = "Send Integration"
  integration_uri    = aws_lambda_function.WebSocketSendMessage.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "SendRoute" {
  api_id         = aws_apigatewayv2_api.chatMachine.id
  route_key      = "sendMessage"
  operation_name = "SendRoute"
  target         = "integrations/${aws_apigatewayv2_integration.SendMessageInt.id}"
}



output "WebSocketURI" {
  value = aws_apigatewayv2_stage.API_Stage_chat.invoke_url
}

