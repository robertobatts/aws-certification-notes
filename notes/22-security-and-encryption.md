# Security and Encryption

## KMS - Key Management Service
- Easy way to control access to your data, AWS manages keys for use
- Fully integrated with IAM for authorization
- Fully integrated with IAM for authorization
- Seamlessly integrated into EBS, S3, Redshift, RDS, SSM, etc...
- You can also use the CLI/SDK
- Able to fully manage the keys and policies to Create, Disable, Enable and Rotation policies
- Able to audit key usage using CloudTrail
- Three type of costs for CMK:
	- AWS Managed Service Default CMK: free
	- User Keys created in KMS: $1/month
	- User Keys imported (must be 256-bit symmetric key): $1/month
- Pay for API call to KMS to KMS ($0.03 / 10,000 calls)
- Can only encrypt up to 4KB of data per call
- To give access to KMS to someone:
	- Make sure the Key policy allows the user
	- Make sure the IAM policy allows the API calls

### Customer Master Key (CMK) Types
- **Symmetric (AES-256 keys)**
	- First offering of KMS, single encryption key that is used to encrypt and decrypt
	- AWS services that are integrated with KMS use Symmetric CMKs
	- Necessary for envelope encryption
	- You never get access to the key unencrypted (you must call KMS API to use it, but you never see the actual value of the key)
- **Asymmetric (RAS and ECC key pairs)**
	- Public (Encrypt) and Private Key (Decrypt) pair
	- Used for Encrypt/Decrypt or Sign/Verify operations
	- The Public key is downloadable, but you can't access the Private Key unencrypted
	- Use case: encryption outside of AWS by users who can't call KMS API

### Copying Snapshots across regions
Keys are bounded to a specific regions. To migrate an encrypted EBS volume to a new region:
- Create a snapshot of the volume, the snapshot will be automatically encrypted with the same key
- Copy the snapshot into the new region by specifying the new key
- Create the new EBS volume from the snapshot, and it will be automatically encrypted with the new key

### Key Policies
- Control access to KMS keys, similar to S3 bucket policies
- Difference: you cannot control access without them
- **Default KMS Key Policy**:
	- Created if you don't provide a specific KMS Key Policy
	- Complete access to the key to the root user = entire AWS account
	- Gives access to the IAM policies to the KMS key
- **Custom KMS Key Policy**:
	- Define users, roles that can access the KMS key
	- Define who can administer the key

### Key Rotation
- For Customer-managed CMK (not AWS Managed)
- If enabled, automatic key rotation happens every year
- Previous key is kept active so you can decrypt old data
- New key has the same CMK ID (only the backing key is changed)

#### Manual Key Rotation
- New key has a different CMK ID
- Keep the previous key active so you can decrypt old data
- Better to use aliases in this case (to hide the change of key for the application)
- Good solution to rotate CMK that are not eligible for automatica rotation (like asymmetric CMK)

## SSM Parameter Store
- Secure storage for configuration and secrets
- Optional Seamless Encryption using KMS
- Serverless, scalable, durable, easy SDK
- Version tracking of configurations / secrets
- Configuration management using path and IAM
- Notifications with CloudWatch Events
- Integration with CloudFormation
- **Standard Tier**
	- 10k parameters max
	- Free
	- Pay $0.05 per 10k requests if you want higher throughput
- **Advanced Tier**
	- 100k parameters max
	- Parameter policies available
	- Charges apply

### Parameters policy
- Allow to assign a TTL to a parameter (expiration data) to force updating or deleting sensitive data such as passwords
- Can assign multiple policies at a time

## AWS Secrets Manager
- Newer service, meant for storing secrets
- Capability to force rotation of secrets every X days
- Automate generation of secrets on rotation (uses Lambda)
- Integration with RDS to synch secrets between database and secret manager
- Secrets are encrypted using KMS
- Mostly meant for RDS integration

## CloudHSM
- Dedicated hardware (HSM = Hardware Security Module)
- AWS manage your encryption hardware
- You manage your own encryption keys entirely (not AWS)
- HSM device is tamper resistant
- Supports both symmetric and asymmetric encryption (SSL/TLS keys)
- No free tier available
- Must use the CloudHSM Client Software
- Redshift supports CloudHSM for database encryption and key management
- Good option to use with SSE-C encryption

## KMS vs CloudHSM
![[kms-vs-cloudhsm.png]]

## AWS Shield
- **AWS Shield Standard**
	- Free service that is activated for every AWS customer
	- Provides protection from attachs such as SYN/UDP Floods, Refletion attacks and other layer 4 and layer 4 attacks
- **AWS Shield Advanced**
	- Optional DDosS mitigation service ($3,000 per month per organization)
	- Protect against more sophisticated attacks on EC2, ELB, CloudFront, GlobalAccelerator and Route53
	- 24/7 access to AWS DDoS respons team (DRP)

## Web Application Firewall (WAF)
- Protects you web apps from common web exploits (layer 7)
- Layer 7 is HTTP ( layer 4 instead is TCP)
- Deploy on ALB, Gateway and CloudFront
- Define Web ACL (Web Access Control List):
	- Rules can include: IP addresses, HTTP headers, HTTP body, or URI strings
	- Protects from common attack - SQL injection and Cross-Site Scripting (XSS)
	- Size constraints, **geo-match (block countries)**
	- **Rate-based rules** for DDoS protection

### Firewall Manager
- Manage rules in all ccounts of an AWS Organization
- Common set of security rules
- WAF rules
- AWS Shield Advanced
- Security Groups for EC2 and ENI resources in VPC

## Guard Duty
- Intelligent Threat discovery to protect AWS Account
- Uses Machine Learning algorithms, anomaly detection, 3rd party data
- One click to enable (30 days trial), no need to install software
- Input data includes:
	- CloudTrail Events Logs - unusual API calls, unauthorized deployments
		- CloudTrail Management Events - create VPC subnet, create trail, ...
		- CloudTrail S3 Data Events - get object, list objects, delete object, ...
	- VPC Flow Logs - unusual internal traffic, unusual IP address
	- DNS Logs - compromised EC2 instances sending encoded data within DNS queries
	- Kubernetes Audit Logs - suspicious activities and potential EKS cluster compromises
- Can setup CloudWatch Event rules to be notified in case of findings

## Amazon Inspector
- Automated Security Assessments
- **For EC2 instances**
	- Leveraging the AWS System Manager (SSM) agent
	- Analyze against unintended network accessibility
	- Analyze the running OS against know vulnerabilities
- **For Containers pushed to ECR**
	- Assessment of containers as they are pushed
- Reporting and integration with AWS Security Hub
- Send findings to Amazon Event Bridge
- Continuous scanning of the infrastructure
- Check for package vulnerabilities
- Check network reachability
- A risk score is associated with all vulnerabilities for prioritization

## Amazon Macie
- Macie is a fully managed data security and data privacy service that uses machine learning and pattern matching to discover and protect your sensitive data in AWS
- Macie helps identify and alert you to sensitive data, such as personally identifiable information (PII)

## Shared Responsibility Model
- AWS responsibility - Security of the Cloud
	- Protecting infrastructure (hardware, software, facilieties and networking) that runs all the AWS services
	- Managed services like S3, DynamoDb, RDS, etc...
- Customer responsibility - Security in the Cloud
	- For EC2 instance, customer is responsible for management of the guest OS (including security patches and updates), firewall and network configuration, IAM permissions
	- Encrypting application data
- Shared controls
	- Patch management, configuration management, awareness and training

