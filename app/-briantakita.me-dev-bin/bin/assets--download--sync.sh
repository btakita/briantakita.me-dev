#!/bin/sh
mkdir -p public/assets
aws s3 sync s3://$AWS_BUCKET/ public/assets
