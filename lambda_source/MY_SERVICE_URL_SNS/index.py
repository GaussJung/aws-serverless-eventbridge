'''
 URL동작점검 처리결과 SNS통보(성공) 
Program : MY_SERVICE_URL_SNS
Author : 정철웅(cwjung123@gmail.com)
Version : 1.0
'''

import os
import json
import sys
import boto3
import datetime


# S38. 데이터 처리 통보 함수 
def publish_sns(msgTitle, msgBody):
    
    my_sns = boto3.client('sns')
    snsArn = os.environ['snsArn']
    # print(snsArn) 
 
    snsResponse = my_sns.publish(
        TopicArn = snsArn,
        Message = msgBody,
        Subject = msgTitle
    )
    # print(snsResponse)
    return snsResponse
 

# S10. 람다 핸들러(기동함수) 시작 
def lambda_handler(event, content):
 
    print("=========== MY_SERVICE_URL_SNS Event Dump v1.0 ============")
 
    # 출력으로 전달할 이벤트 덤프 
    eventDump = json.dumps(event)
    # print(eventDump)

    requestPayload = event['requestPayload']
 
    # 모니터링 점검여부 True : 성공, False : 실패 
    checkStatus = event['responsePayload']['statusCode']
    checkURL = event['responsePayload']['checkURL']
 
    # 현재일자를 통해서 현재시간을 출력 YYYYmmdd:HHMMSS  
    cdate = datetime.datetime.today() # 현재 날짜 가져오기
    currtime = cdate.strftime("%Y.%m.%d %H:%M:%S")   
    
    # 체크가 정상적으로 된경우 >> day일 경우 레코드 숫자,  체크가 비정상인 정우 abnormal 
    if checkStatus == 200:
        print(f"C2-A. Connection success for {checkURL} at {currtime}")
        outSnsResponse = publish_sns(f"My-URL success for {checkURL}", eventDump)
    else:
        # 수신전화번호 : os.environ['smsReceiverPhone'] 환경변수에 저장 (01073579090)
        pureCheckURL = checkURL.split('//')[1]
        #print(f"C3-B. Connection fail for {checkURL}")
        outSnsResponse = publish_sns(f"My-URL fail for {checkURL} at {currtime}", eventDump)

    # SNS전송 
    # print("C3. outSnsResponse : ", json.dumps(outSnsResponse))
    return {"result":eventDump}
 
