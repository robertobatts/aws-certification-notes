# Security and Encryption

## KMS - Key Management Service
- Easy way to control access to your data, AWS manages keys for use
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
- Good solution to rotate CMK that are not eligible for automatic rotation (like asymmetric CMK)

## KMS Multi-Region Keys
- Replicate the same key with the same id and same rotation across multiple regions
- You can encrypt with this in one region, and decrypt in another region
- No need of re-ecnrypting data or making cross-Region API calls when you move data to another region
- KMS Multi-Region are NOT global, it is Primary + Replicas
- Each Multi-Region key is managed independently with their own key policy
- Use cases: global client-side encryption, encryption on Global DynamoDB, Global Aurora


## S3 Replication with Encryption
- If you enable S3 Replication from one bucket to another, unencrypted objects and objects encrypted with SSE-S3 are replicated by default
- Objects encrypted with SSE-C (customer provided key) are never replicated
- For objects encrypted with SSE-KMS, you have to enable the option
	- Specify which KMS Key to encrypt the objects within the target bucket
	- Adapt KMS Key Policy for the target key
	- Set IAM Role with kms:Decrypt for the source KMS Key and kms:Encrypt for the target KMS Key
	- You might get KMS throttling errors, in which case you can ask for a Service Quotas increase
- You can use multi-region AWS KMS Keys, but they are currently treated as independent keys by S3 (the objects will still be decrypted and then encrypted)

## Encrypted AMI Sharing Process
- AMI in Account A is encrypted with KMS Key from Account A
- To launch an EC2 instance in Account B from this AMI you must modify the image atribute to add a Launch Permission which corresponds to the specified target AWS account
- You must share the KMS Key used to encrypt the snapshot of the AMI, with the Account B/IAM Role
- The IAM Role/User in Account B must have the permissions to DescribeKey, ReEncrypted, CreateGrant, Decrypt
- When launching an EC2 instance from the AMI, optionally the Account B can specify a new KMS key in its own account to re-encrypt the volumes

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

## AWS Certificate Manager (ACM)
- Easily provision, manage and deploy TLS (SSL) Certificates
- Provide in-flight encryption for websites (HTTPS)
- Supports both public and private TLS certificates
- Free of charge for public TLS certificates
- Automatic TLS certificate renewal
- You can load the certificate on ELB, CloudFront, API Gateway
- You cannot use it with EC2

### Requesting Public Certificates
1. List domain names to be included in the certificate
	- Fully Qualified Domain Name (FQDN): corp.example.com
	- Wildcard Domain: \*.example.com
2. Select Validation Method: DNS Validation or Email validation
	- DNS Validation is preferred for automation purposes
	- Email validation will send emails to contact addresses in the WHOIS database
	- DNS Validation will leaverage a CNAME record to DNS config
3. It will take a few hours to get verified
4. The Public Certificate will be enrolled for automatic renewal
	- ACM automatically renews ACM-generated certificates 60 days before expiry

### Importing Public Certificates
- You can generate the certificate outside of ACM and then import it
- No automatic renewal, must import a new certificate before expiry
- ACM sends daily expiration events starting 45 days prior to expiration
	- The number of days can be configured
	- Events are appearing in EventBridge
- AWS Config has a manged rule named *acm-certificate-expiration-check* to check for expiring certificates (configurable number of days), if you activate it it will send an event to EventBridge when the rule is not compliant

### Integration with API Gateway
- Create a Custom Domain Name in API Gateway
- Edge-Optimized (default):
	- Request are routed through the CloudFront Edge locations
	- The API Gateway still lives in only one region
	- The TLS Certificate must be in the same regions as CloudFront, in us-east-1
	- Then setup CNAME or A-Alias record in Route 53
- Regional:
	- The TLS Certificate must be imported on API Gateway, in the same regions as the API Stage
	- Then setup CNAME or A-Alias record in Route 53

## Web Application Firewall (WAF)
- Protects you web apps from common web exploits (layer 7)
- Layer 7 is HTTP (layer 4 instead is TCP/UDP)
- Deploy on ALB, API Gateway and CloudFront, AppSync GraphQL, Cognito User Pool 
- Define Web ACL (Web Access Control List):
	- Rules can include: IP addresses, HTTP headers, HTTP body, or URI strings
	- Protects from common attack - SQL injection and Cross-Site Scripting (XSS)
	- Size constraints, **geo-match (block countries)**
	- **Rate-based rules** for DDoS protection
- Web ACL are Regional, except for CloudFront where they are defined globally
- A rule groups is a reusable set of rules that you can add to a Web ACL

## AWS Shield
- **AWS Shield Standard**
	- Free service that is activated for every AWS customer
	- Provides protection from attachs such as SYN/UDP Floods, Reflection attacks and other layer 3 and layer 4 attacks
- **AWS Shield Advanced**
	- Optional DDoS mitigation service ($3,000 per month per organization)
	- Protect against more sophisticated attacks on EC2, ELB, CloudFront, GlobalAccelerator and Route53
	- 24/7 access to AWS DDoS response team (DRP)
	- Protect against higher fees during usage spikes due to DDoS
	- Automatically creates, evaluates and deploys AWS WAF rules to mitigate layer 7 attacks

## Firewall Manager
- Manage rules in all accounts of an AWS Organization
- You can set a security policy (common set of security rules)
	- WAF rules
	- AWS Shield Advanced
	- Security Groups for EC2, ALB and ENI resources in VPC
	- Rules for AWS Network Firewall (VPC level)
	- Amazon Route 53 Resolver DNS Firewall
	- Policies are created at the region level
- Rules are applied to new resources as they are created (good for compliance) across all and future accounts in your Organization

## WAF vs Firewall Manager vs Shield
- For granular protection of your resources, WAF alone is the correct choice
- If you want to use WAF across accounts, accelerate WAF configuration, automate the protection of new resources, use Firewall Manager with WAF
- Shield Advanced adds additional features on top of WAF, such as dedicated support from the Shield Response Team and advanced reporting
- If you're prone to frequen DDoS attacks, consider purchasing Shield Advanced

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

