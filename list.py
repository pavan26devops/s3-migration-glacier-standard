#!/usr/bin/python
import boto3

def iterate_bucket_items(bucket):
    session = boto3.Session(profile_name='aws-profile-name')
    client = session.client('s3')
    paginator = client.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(Bucket=bucket)

    for page in page_iterator:
        for item in page['Contents']:
            yield item


for i in iterate_bucket_items(bucket='bucket_name'):
    print i
