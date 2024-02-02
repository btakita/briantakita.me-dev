#!/bin/sh
aws s3 sync public/assets s3://$AWS_BUCKET/
