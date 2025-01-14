##########  Step1. IAM ##########
서버리스에 필요한 주요 권한을 포함하는 역할을 생성 

1) 역할생성 
trust_dev_serverless.json
-- START of 파일내용 --
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
				"apigateway.amazonaws.com",
				"lambda.amazonaws.com",
				"sqs.amazonaws.com",
				"sns.amazonaws.com",
				"ec2.amazonaws.com",
				"dynamodb.amazonaws.com",
				"scheduler.amazonaws.com",
				"cloudformation.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
-- END of 파일내용 --

aws iam create-role --role-name  my_role_dev_serverless  --assume-role-policy-document file://trust_dev_serverless.json 
(결과) 
{
    "Role": {
        "Path": "/",
        "RoleName": "my_role_dev_serverless",
        "RoleId": "AROAYJCQCX5TJS6WZCS3M",
        "Arn": "arn:aws:iam::111122223333:role/my_role_dev_serverless",
        "CreateDate": "2025-01-13T04:25:31+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": [
                            "apigateway.amazonaws.com",
                            "lambda.amazonaws.com",
                            "sqs.amazonaws.com",
                            "sns.amazonaws.com",
                            "ec2.amazonaws.com",
                            "dynamodb.amazonaws.com",
                            "scheduler.amazonaws.com",
                            "cloudformation.amazonaws.com"
                        ]
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
    }
}


2) 정책생성 
aws iam create-policy --policy-name my_policy_log  --policy-document file://my_policy_log.json 
aws iam create-policy --policy-name my_policy_dynamodb  --policy-document file://my_policy_dynamodb.json 
aws iam create-policy --policy-name my_policy_apigateway  --policy-document file://my_policy_apigateway.json 
aws iam create-policy --policy-name my_policy_queue  --policy-document file://my_policy_queue.json 
aws iam create-policy --policy-name my_policy_lambda  --policy-document file://my_policy_lambda.json 
aws iam create-policy --policy-name my_policy_ec2  --policy-document file://my_policy_ec2.json 
aws iam create-policy --policy-name my_policy_sns  --policy-document file://my_policy_sns.json 
(결과)

{
    "Policy": {
        "PolicyName": "my_policy_log",
        "PolicyId": "ANPAYJCQCX5TNAKPQI4MD",
        "Arn": "arn:aws:iam::111122223333:policy/my_policy_log",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2025-01-13T04:52:51+00:00",
        "UpdateDate": "2025-01-13T04:52:51+00:00"
    }
}
-- 7개 생략 -- 

3) 역할에 정책 붙이기 
aws iam attach-role-policy --role-name my_role_dev_serverless --policy-arn  arn:aws:iam::111122223333:policy/my_policy_log
aws iam attach-role-policy --role-name my_role_dev_serverless --policy-arn  arn:aws:iam::111122223333:policy/my_policy_dynamodb
aws iam attach-role-policy --role-name my_role_dev_serverless --policy-arn  arn:aws:iam::111122223333:policy/my_policy_apigateway
aws iam attach-role-policy --role-name my_role_dev_serverless --policy-arn  arn:aws:iam::111122223333:policy/my_policy_queue
aws iam attach-role-policy --role-name my_role_dev_serverless --policy-arn  arn:aws:iam::111122223333:policy/my_policy_lambda
aws iam attach-role-policy --role-name my_role_dev_serverless --policy-arn  arn:aws:iam::111122223333:policy/my_policy_ec2
aws iam attach-role-policy --role-name my_role_dev_serverless --policy-arn  arn:aws:iam::111122223333:policy/my_policy_sns 
(결과 내용없음) 
 
 
##########  Step2. SNS (Simple Notification Service)  ##########
1) Topic 생성 
(결과) 
aws sns create-topic --name  my-service-monitor
{
    "TopicArn": "arn:aws:sns:ap-northeast-2:111122223333:my-service-monitor"
}

2) Subscription 생성 
aws sns subscribe --topic-arn  arn:aws:sns:ap-northeast-2:111122223333:my-service-monitor --protocol email --notification-endpoint  myemailaddress@gmail.com
(결과) 
{
    "SubscriptionArn": "pending confirmation"
}
--> 메일에 접속하여 verification진행 
(메일내용)
You have chosen to subscribe to the topic:
arn:aws:sns:ap-northeast-2:111122223333:my-service-monitor

To confirm this subscription, click or visit the link below (If this was in error no action is necessary):
Confirm subscription
 
3) 메시지 발송 
: 기본제목(AWS Notification Message) 이메일 발송 
aws sns publish --topic-arn arn:aws:sns:ap-northeast-2:111122223333:my-service-monitor   --message "SNS Test!"
(결과)
{
    "MessageId": "a34ab345-0cc9-5fd9-9e91-ecbb83bce8b3"
}
(비고) 제목포함 이메일 발송 
aws sns publish --topic-arn arn:aws:sns:ap-northeast-2:111122223333:my-service-monitor  --subject "SNS Title 2025"  --message "SNS Test2!"

##########  Step3. Lambda Function ##########
(설명)  cloudFormation 스택으로 함수 생성 
MY_SERVICE_URL_CHECKER : EventBridge 스케줄러의 호출에 반응하는 함수로서 URL의 동작여부를 확인함 (응답코드 200) 
MY_SERVICE_URL_URL : MY_SERVICE_URL_CHECKER의 동작 성공시 후속처리로서 SNS발송 
 
myServiceLambdaTemplate.yml 내용 
1) Lambda 함수 두개 생성 Template 작성 
trust_dev_serverless.json
-- START of 파일내용 --
Resources:
  Lambda1Function:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: MY_SERVICE_URL_CHECKER
      Description: Monitoring URL Checker
      Runtime: python3.12
      Handler: index.lambda_handler
      MemorySize: 128
      Timeout: 10
      EphemeralStorage:
        Size: 512
      Environment:
        Variables:
          checkTargetURL: https://daum.net
      Architectures:
        - x86_64
      Code:
        ZipFile: |
            import json
            def lambda_handler(event, context):
                print(event)
                return {
                    'statusCode': 200,
                    'body': json.dumps('Lambda1-This is MY_SERVICE_URL_CHECKER V1.0')
                }
      Role: arn:aws:iam::111122223333:role/my_role_dev_serverless
  Lambda2Function:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: MY_SERVICE_URL_SNS
      Description: Send Notification After Check URL status
      Runtime: python3.12
      Handler: index.lambda_handler
      MemorySize: 128
      Timeout: 10
      EphemeralStorage:
        Size: 512
      Environment:
        Variables:
          snsArn: arn:aws:sns:ap-northeast-2:111122223333:my-service-monitor
      Architectures:
        - x86_64
      Code:
        ZipFile: |
            import json
            def lambda_handler(event, context):
                print(event)
                return {
                    'statusCode': 200,
                    'body': json.dumps('Lambda2-This is MY_SERVICE_URL_SNS V1.0')
                }
      Role: arn:aws:iam::111122223333:role/my_role_dev_serverless

  LambdaAsyncConfig:
    Type: AWS::Lambda::EventInvokeConfig
    Properties:
      DestinationConfig:
        OnSuccess:
          Destination:
            Fn::GetAtt: ['Lambda2Function', 'Arn']
      FunctionName: !Ref Lambda1Function
      Qualifier: $LATEST


-- END of 파일내용 --

2) Stack생성 cloudFormation CLI구동  
: 스택생성 
aws  cloudformation  create-stack  --template-body  file://myServiceLambdaTemplate.yml --stack-name   LambdaURLCheckerV1   --tags="Key=Name,Value=Training"    --capabilities CAPABILITY_NAMED_IAM
(결과)
{
    "StackId": "arn:aws:cloudformation:ap-northeast-2:111122223333:stack/LambdaURLCheckerV1/9b1e5bf0-d17d-11ef-87b5-06735a796d1b"
}
: 스택삭제 
aws  cloudformation  delete-stack  --stack-name   EC2enqvpc-B

3) 함수내용 갱신 
cd ~/awswork/eventbridge/lambda_source/MY_SERVICE_URL_CHECKER   --> 이 안에는 index.py 파일이 한 개 있음. 
zip -r func_checker.zip *
aws lambda update-function-code --function-name MY_SERVICE_URL_CHECKER  --zip-file  fileb://func_checker.zip

cd ~/awswork/eventbridge/lambda_source/MY_SERVICE_URL_SNS    --> 이 안에는 index.py 파일이 한 개 있음. 
zip -r func_sns.zip *
aws lambda update-function-code --function-name MY_SERVICE_URL_SNS --zip-file  fileb://func_sns.zip

4) 함수 동작 확인 
>>> MY_SERVICE_URL_CHECKER
A)기본동작 
B) 성공이벤트 추가 후 Test  --> naver_success 
{
  "version": "1.5",
  "checkURL": "https://naver.com"
}
C) 실패이벤트 추가 후 Test  --> naver_fail 
{
  "version": "1.5",
  "checkURL": "https://naver111.com"
}

>>> MY_SERVICE_URL_SNS 
A) 성공 이벤트 추가후 동작 
{
  "version": "1.1",
  "requestPayload": {
    "version": "1.5",
    "checkURL": "https://google.com"
  },
  "responsePayload": {
    "statusCode": 200,
    "checkURL": "https://google.com"
  }
}

B) 실패 이벤트 추가후 동작 
{
  "version": "1.1",
  "requestPayload": {
    "version": "1.5",
    "checkURL": "https://naver111.com"
  },
  "responsePayload": {
    "statusCode": -100,
    "checkURL":  "https://naver111.com"
  }
}



##########  Step4. Event Bridge Scheduler ##########
30분 혹은 1시간 간격으로 동작하는 스케줄러 동작 
초기에 1회 동작하는 스캐줄러를 구동하여 정상여부를 확인후 주기 스캐줄러를 동작시킴 

참조 : https://docs.aws.amazon.com/cli/latest/reference/scheduler/create-schedule.html 

(명령어 for 스케줄러 생성) 
aws scheduler create-schedule --name lambda-templated-schedule --schedule-expression 'rate(5 minutes)' \
--target '{"RoleArn": "ROLE_ARN", "Arn":"FUNCTION_ARN", "Input": "{ \"Payload\": \"TEST_PAYLOAD\" }" }' \
--flexible-time-window '{ "Mode": "OFF"}'

(명령어 for 스케줄러 변경) 
aws scheduler update-schedule --name lambda-templated-schedule --schedule-expression 'rate(5 minutes)' \
--target '{"RoleArn": "ROLE_ARN", "Arn":"FUNCTION_ARN", "Input": "{ \"Payload\": \"TEST_PAYLOAD\" }" }' \
--flexible-time-window '{ "Mode": "OFF"}'

(특정시간)  --schedule-expression 'at(2025-01-14T11:50:00)' 
(CRON)  --schedule-expression 'cron(30 8 * * ? *)'

1) 1회성 스케줄러 
(실행) 
aws scheduler create-schedule --name my-url-checker-once   --schedule-expression 'at(2025-01-14T11:50:00)'  \
--target '{"RoleArn": "arn:aws:iam::111122223333:role/my_role_dev_serverless", "Arn":"arn:aws:lambda:ap-northeast-2:569251118950:function:MY_SERVICE_URL_CHECKER", "Input": "{ \"version\": \"0.90\", \"checkURL\": \"https://www.youtube.com\"  }" }' \
--schedule-expression-timezone "Asia/Seoul" \
--flexible-time-window '{ "Mode": "OFF"}'
(결과)
{
    "ScheduleArn": "arn:aws:scheduler:ap-northeast-2:111122223333:schedule/default/my-url-checker-once"
}

(변경1) 
aws scheduler update-schedule --name my-url-checker-once   --schedule-expression 'at(2025-01-14T11:50:00)'  \
--target '{"RoleArn": "arn:aws:iam::111122223333:role/my_role_dev_serverless", "Arn":"arn:aws:lambda:ap-northeast-2:569251118950:function:MY_SERVICE_URL_CHECKER", "Input": "{ \"version\": \"0.91\", \"checkURL\": \"https://www.youtube.com\"  }" }' \
--schedule-expression-timezone "Asia/Seoul" \
--flexible-time-window '{ "Mode": "OFF"}'
{
    "ScheduleArn": "arn:aws:scheduler:ap-northeast-2:111122223333:schedule/default/my-url-checker-once"
}

(변경2)
aws scheduler update-schedule --name my-url-checker-once   --schedule-expression 'at(2025-01-14T11:52:00)'  \
--target '{"RoleArn": "arn:aws:iam::111122223333:role/my_role_dev_serverless", "Arn":"arn:aws:lambda:ap-northeast-2:569251118950:function:MY_SERVICE_URL_CHECKER", "Input": "{ \"version\": \"0.92\", \"checkURL\": \"https://www.facebook.com\"  }" }' \
--schedule-expression-timezone "Asia/Seoul" \
--flexible-time-window '{ "Mode": "OFF"}'
 
(변경3)
aws scheduler update-schedule --name my-url-checker-once   --schedule-expression 'at(2025-01-14T11:56:00)'  \
--target '{"RoleArn": "arn:aws:iam::111122223333:role/my_role_dev_serverless", "Arn":"arn:aws:lambda:ap-northeast-2:569251118950:function:MY_SERVICE_URL_CHECKER", "Input": "{ \"version\": \"0.93\", \"checkURL\": \"https://www.face-boo11k.com\"  }" }' \
--schedule-expression-timezone "Asia/Seoul" \
--flexible-time-window '{ "Mode": "OFF"}'

(변경4)
aws scheduler update-schedule --name my-url-checker-once   --schedule-expression 'at(2025-01-14T11:58:00)'  \
--target '{"RoleArn": "arn:aws:iam::111122223333:role/my_role_dev_serverless", "Arn":"arn:aws:lambda:ap-northeast-2:569251118950:function:MY_SERVICE_URL_CHECKER", "Input": "{ \"version\": \"0.94\", \"checkURL\": \"https://adm.ebaeum.com\"  }" }' \
--schedule-expression-timezone "Asia/Seoul" \
--flexible-time-window '{ "Mode": "OFF"}'
 
2) 주기 스케쥴러 생성 
(실행) 
aws scheduler create-schedule --name my-url-checker   --schedule-expression 'rate(5 minutes)' \
--target '{"RoleArn": "arn:aws:iam::111122223333:role/my_role_dev_serverless", "Arn":"arn:aws:lambda:ap-northeast-2:569251118950:function:MY_SERVICE_URL_CHECKER", "Input": "{ \"Payload\": \"TEST_PAYLOAD777\" }" }' \
--flexible-time-window '{ "Mode": "OFF"}'
(결과)
{
    "ScheduleArn": "arn:aws:scheduler:ap-northeast-2:111122223333:schedule/default/my-url-checker"
}
 
(변경1) 
aws scheduler update-schedule --name my-url-checker   --schedule-expression 'rate(10 minutes)' \
--target '{"RoleArn": "arn:aws:iam::111122223333:role/my_role_dev_serverless", "Arn":"arn:aws:lambda:ap-northeast-2:569251118950:function:MY_SERVICE_URL_CHECKER", "Input": "{ \"version\": \"1.0\", \"checkURL\": \"https://www.seoul.go.kr\"  }" }' \
--flexible-time-window '{ "Mode": "OFF"}'

(변경2) 
aws scheduler update-schedule --name my-url-checker   --schedule-expression 'rate(60 minutes)' \
--target '{"RoleArn": "arn:aws:iam::111122223333:role/my_role_dev_serverless", "Arn":"arn:aws:lambda:ap-northeast-2:569251118950:function:MY_SERVICE_URL_CHECKER", "Input": "{ \"version\": \"1.1\", \"checkURL\": \"https://www.google.com\"  }" }' \
--flexible-time-window '{ "Mode": "OFF"}'
 
