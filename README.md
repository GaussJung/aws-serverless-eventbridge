# aws-serverless-eventbridge v1.34  
Practice using  AWS eventbridge, SNS, Lambda for monitoring IT Resources. 

■ Cloud Architect Diagram

<img src="https://github.com/GaussJung/aws-serverless-eventbridge/blob/master/resource/eventbridge_serverless.jpg" alt="EventBridge" width="860"  border="1px solid gray"  />
 
■ AWS Resources    
- Lambda : Serverless Function 2 (Checker and Notificator)   
- SNS : Simple Notification --> Email Subscription   
- EventBridge : 30 minutes Regular Event Schedule   

■ Pre-Requsite   
- AWS Account   
- AWS CLI Version2   
- EC2 practice instance
- Python Basic Grammar    
- Understanding about AWS IAM-Role,Policy    

■ Estimation   
- Beginner : 2H
- Skilled user : 1H   

■ Directory Structure    
- iam_ref : files for creaating IAM role and policies. 
- lambda_source : lambda source files for main logic. 
- lambda_template : cloudFormation template for creating Lambda functions.  

■ Initial Process after launching an EC2 for this practice. 
- mkdir ~/awswork  (Temp Woring Directory - Recommendation)
- cd ~/awswork 
- git clone https://github.com/GaussJung/aws-serverless-eventbridge
- cd aws-serverless-eventbridge
 
■ Guide     
- I recommend you to read [CIL V2 Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/index.html) and [document](https://docs.aws.amazon.com/serverless/) about AWS severless before doing this practice. 
- Follow [script guide](https://github.com/GaussJung/aws-serverless-eventbridge/blob/57da30b138ff4ee9bab58ff6036c3c4ae9e0bd8e/cli_helper_command.sh) after setting pre-requsite.          



 

