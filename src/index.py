import os
import boto3
import json
from importlib.metadata import version

from_email = os.getenv("SES_FROM_EMAIL")
client = boto3.client("ses")


def lambda_handler(event, context):
    print(version('boto3'))
    print(event)
    body = event["body"]

    message = body["message"]
    title = body["title"]

    destinations = []  # à determiner

    email_message = {
        "Body": {
            "Html": {
                "Charset": "utf-8",
                "Data": message,
            },
        },
        "Subject": {
            "Charset": "utf-8",
            "Data": title,
        },
    }
    try:
        print(f"from : {from_email}")
        print(f"to : {destinations}")

        ses_response = client.send_email(
            Destination={
                "ToAddresses": destinations,
            },
            Message=email_message,
            Source=from_email,
        )

        print(f"ses response id received: {ses_response['MessageId']}.")
        print(ses_response)
        return {
            "isBase64Encoded": False,
            "statusCode": 200,
            "body": json.dumps(ses_response)
        }
    except Exception as e:
        print(e)
        return {
            "isBase64Encoded": False,
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
