# Amazon S3 Introduction

## Buckets
- S3 allows people to store objectes (files) in buckets (directories)
- Buckets must have a globally unique name
- Buckets are defined at the region level
- Naming convention: no uppercase, no underscore, 3-63 characters long, not an IP, must start with lowercase letter or number

## Objects
- Objects have a Key
- The key is the full path to the file (e.g. s3://my-bucket/my_folder/my_file.txt)
- Object values are the content of the body
- Max object size = 5TB
- If you want to upload more than 5GB, you must use "multi-part upload"
- Every object has metadata
- You can set tags
- They have Version ID if versioning is enabled

## Versioning
- Versioning can be enabled at the bucket level
- If you upload a file with the same key, it will increment the version
- It is a best practice to version your buckets
- It protects against unintended deletes (ability to restore a version)
- Easy roll back to previous version
- Files that are not versioned will have version = null
- Suspending versioning does not delete the previous versions

## Encryption
There are 4 methods of encrypting objects in S3:
- SSE-S3: encrypt S3 objects using keys handled and managed by AWS
- SSE-KMS: leverage AWS Key Management Service to manage encryption keys
- SSE-C: you have to manage your own encryption keys
- Client Side Encryption

### SSE-S3
- Object is encrypted server side (SSE = Server Side Encryption)
- AES-256 encryption type
- Must set header when you send the object: `"x-amz-server-side-encryption": "AES256"`

### SSE-KMS
- KMS advantages: user control + audit trail
- Must set header: `"x-amz-server-side-encryption":"aws:kms"`

### SSE-C
- S3 does not store the encryption key you provide
- HTTPS must be used, because you have to send the secret to AWS
- Encryption key must be provided in the headers for every request
- You need to provide the key for retrieving the files too
- Can only be done through the CLI

### Client Side Encryption
- You can use client library such as Amazon S3 Encryption Client
- Clients must encrypt data themselves before sending to S3
- Clients must decrypt data themselves when retrieving from S3
- Customer fully manages the keys and ancryption cycle

### Encryption in transit (SSL/TLS)
- Amazon S3 exposes:
	- HHTP endpoint: non encrypted
	- HTTPS endpoint: encryption in flight
- You're free to use the endpoint you want, but HTTPS is recommended
- HTTPS is mandatory for SSE-C
- Encryption in flight is also called SSL/TLS

## Security
- **User based**
	- IAM policies - which API calls should be allowed for a specific user from IAM console
- **Resource based**
	- Bucket Policies - bucket wide rules from the S3 console - allows cross account
	- Object Access Control List (ACL) - finer grain
	- Bucket Access Control List (ACL) - less common

### Bucket Policies
- JSON based policies
	- Resources: buckets and objects
	- Actions: set of API to Allow or Deny
	- Principal: the account or user to apply the policy to

### Bucket settings fro Block Public Access
- Block public access to buckets and objects granted through
	- *new* access control lists
	- *any* access control lists
	- *new* public bucket or access point policies
- Block public and cross-account acess to buckets and objects through any public bucket or access point policies

### Other
- Networking
	- Supports VPC endpoints
- Logging and Audit
	- S3 Access Logs can be stored in other S3 buckets
	- API calls can be logged in AWS CloudTrail
- User Security
	- MFA Delete: MFA can be required in versioned buckets to delete objects
	- Pre-Signed URLs: urls that are valid only for a limited time

## S3 Websites
- S3 can host static websites and have them accessible on the www
- If you get a 403 (Forbidden) error, make sure the bucket policy allows public reads!
- The website URL will be bucket-name.s3-website.AWS-region.amazonaws.com

## CORS
- An **origin** is a scheme (protocol), host (domain) and port
- CORS means Cross-Origin Resource Sharing
- Web Browser based mechanism to allow requests to other origins while visiting the main origin
- The requests won't be fulfilled unless the other origin allows for the requests, using CORS Headers (e.g. Access-Control-Allow-Origin)

## S3 CORS
- If a client does a cross-origin request on our S3 bucket, we need to enable the correct CORS headers
- You can allow for a specific origin or for * (all origins)