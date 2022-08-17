# generate root access keys
aws configure --profile root-mfa-delete-demo

# enable mfa delete
aws s3api put-bucket-versioning --bucket mfa-demo-robertobatts --versioning-configuration Status=Enabled,MFADelete=Enabled --mfa "arn-of-mfa-device mfa-code" --profile root-mfa-delete-demo

# disable mfa delete
aws s3api put-bucket-versioning --bucket mfa-demo-robertobatts --versioning-configuration Status=Enabled,MFADelete=Disabled --mfa "arn-of-mfa-device mfa-code" --profile root-mfa-delete-demo
