#!/bin/sh
aws s3 cp public/assets s3://$AWS_BUCKET/ --recursive
