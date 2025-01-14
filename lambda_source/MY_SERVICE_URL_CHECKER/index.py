'''
URL Monitoring
Program : MY_SERVICE_URL_CHECKER
Author : 정철웅(cwjung123@gmail.com)
Version : 1.0 
'''

import os
import json
import urllib.request


# HTML본문내용 확인 
def get_check_response(parameterURL):

    # print('T4-0 get_check_response ===============')
    # print(parameterURL)

    outContent = ''  # htmlContent전달 

    try:
        # 요청 호출 
        req = urllib.request.Request(parameterURL)

        with urllib.request.urlopen(req) as response:
            # TargetURL본문 
            outContent = response.read()

    except Exception as e:
        print("Error :\n", str(e) )
        return "" 

    return outContent

# HTML상태코드 체크 (200:정상)
def get_check_status(parameterURL):

    statusCode = -1 # 전달 상태 코드 

    try:
        # 요청 호출 
        req = urllib.request.Request(parameterURL)
  
        with urllib.request.urlopen(req) as response:

            # print("T4-1 response=\n", json.dumps(response))
            outResponseData = response.read()
    
            # print("T4-2 outResponseData=", str(outResponseData) )
            statusCode = response.status 

    except Exception as e:
        print("Error :\n", str(e) )
        return -100

    return statusCode

# 함수 진입 핸들러 
def lambda_handler(event, context):

    print("=== MY_SERVICE_URL_CHECKER v1.0 ===")
    # print("event : ", json.dumps(event))
 
    # check대상도메인 
    if 'checkURL' in event:
        checkTargetURL = event['checkURL']
        print("T3-A Event checkTargetURL : " + checkTargetURL)
    elif os.environ.get('checkTargetURL') is not None:
        checkTargetURL = os.environ.get('checkTargetURL')
        print("T3-B OS checkTargetURL : " + checkTargetURL)        
    else:
        checkTargetURL = "https://www.google.com"   # Default checkURL 
        print("T3-C Default checkTargetURL : " + checkTargetURL)
 
    # responseContent = get_check_response(checkTargetURL)
    # print("T4-2 responseContent\n" + str(responseContent) )

    checkCode = get_check_status(checkTargetURL)
    # print("T5-2 checkCode : " + str(checkCode) )
 
    return {
        'statusCode': checkCode,
        'checkURL': checkTargetURL,
         # 'content': responseContent
    }

