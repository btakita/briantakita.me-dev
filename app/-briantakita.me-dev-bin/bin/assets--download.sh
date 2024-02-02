#!/bin/sh
mkdir -p public/assets
aws s3 cp s3://$AWS_BUCKET/ public/assets --recursive
