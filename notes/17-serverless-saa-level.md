# Serverless for Solutions Architect

## Lambda
- They are virtual functions, no servers to manage
- Limited by time (15 minutes max execution)
- Run on-demand, when you don't use it, the function is not running
- Scaling is automated
- Easy Pricing:
	- Pay per request and compute time
	- Free tier of 1million requests and 400,000 GBs of compute time
- Integrated with the whole AWS suite of services
- Integrated with many programing languages
- Easy monitorign through AWS CloudWatch
- Easy to get more resources per functions
- Increasing RAM will also improve CPU and network
- You can run a Lambda Container Image
	- The container image must implement the Lambda Runtime API
	- ECS/Fargate is preferred for running arbitrary Docker images

### Limits
- Execution
	- Memoru allocation: 128 MB - 10 GB
	- Maximum execution time: 15 minutes
	- Environment variables (4 KB)
	- Disk capacity in the function container (in /tmp): 512 MB
	- Concurrency executions: 1000 (can be increased)
- Deployment:
	- Lambda function deployment size (compressed .zip): max 50 MB
	- Size of uncompressed deployment (code + dependencies): 250 MB
	- Can use the /tmp directory to load other files at startup

### Lambda@Edge
- It deploys the function globally, like a CDN
- Pay only for what you use
- You can use Lambda to change CloudFront requests and responses:
	- After CloudFront reives a request from a viewr
	- Before Cloudfront forwards the request to the origin
	- After CloudFront receives the response from the origin
	- Before CloudFront forwards the response to the viewer
- Use cases: dynamic web application at the edge, SEO, Bot Mitigation at the edge, real-time image transformation, A/B testing

#### Example of global application with Lambda@Edge
![[lambda-edge-app-example.png]]

### Lambda in VPC
- By default your Lambda function is launched outside your own VPC (in an AWS-owned VPC), therefore it cannot access resources in your VPC (RDS, ElastiCache, internal ELB,...)
- To launch it in your VPC, you must define the VPC ID, the subnets and the security groups
- Lambda will create an ENI in your subnets

![[lambda-in-vpc.png]]

#### Lambda with RDS Proxy
- If Lambda functions directly access your database, they may open too many connections under high load
- RDS proxy will solve this issue by pooling and sharing DB connections
- It improves availability by reducing by 66% the failover time and preserving connections
- Improve security by enforcing IAM authentication and storing credentials in Secrets Manager
- The Lambda function must be deployed in your VPC, because RDS Proxy is never publicly accessible

![[lambda-rds-proxy.png]]

## DynamoDB
- Fully managed, highly available with replication across multiple AZs
- NoSQL database with transaction support
- Scales to massive workloads, distributed database
- Millions of requests per seconds, trillions of row, 100s of TB of storage
- Fast and consistent performance (single-digit millisecond)
- Integrated with IAM for security, authorization and administration
- Enables event driven programming with DynamoDB Streams
- Low cost and auto-scaling capabilities
- Standard and Infrequent Access table class

### Basics
- DynamoDB is made of Tables
- Each table has a Primary Key (must be decided at creation time)
- PK can be made of 2 columns (Partition Key + Sort Key)
- Each table can have an infinite number of items (rows)
- Each item has attributes (columns), they can be added over time and can be null
- Maximum size of an item is 400KB
- Data types suported are:
	- Scalar Types - String, Number, Binary, Boolean, Null
	- Document Types - List, Map
	- Set Types - String Set, Number Set, Binary Set

### Read/Write Capacity Modes
- Control how you manage your table's capacity
- **Provisioned Mode** (default)
	- You specify the number of reads/writes per second
	- You need to plan capacity beforehand
	- Pay for provisioned Read Capacity Units (RCU) and Write Capacity Units (WCU)
	- Possibility to add auto scaling mode for RCU and WCU
- **On-Demand Mode**
	- Read/Writes automatically scale up/down with your workloads
	- No capacity planning needed
	- Great for unpredictable workloads
	- Pay for what you use, more expensive

### DynamoDB Accelerator (DAX)
- Fully managed, highly available, seamless in-memory cache for DynamoDB
- Help solve read congestion by caching
- Microseconds latency for cached data
- Doesn't require application logic modification

### DynamoDB Streams
- ORdered stream of item-level modifications (create/update/delete) in a table
- Stream records can be:
	- Sent to Kinesis Data Streams (1 year retention in this case)
	- Read by Lambda
	- Ready by Kinesis Client Library applications
	- Data retention for up to 24 hours
- Use cases:
	- React to changes in real-time
	- Analytics
	- Insert into derivative tables

### Global Tables
- Make a DynamoDB table accessible with low latency in multiple regions
- Active-Active replication
- Applications can read and write to the table in any region
- Must enable DynamoDB Streams as a pre-requisite

### Time To Live
- Automatically delete items after an expiry timestamp

### Indexes
- Global Secondary Indexes (GSI) and Local Secondary Indexes (LSI)
- Allow to query on attributes other than the Primary Key

### Transactions
- Allow you to write to two tables at the same time, or to none of them

### Backups for disaster recovery
- Continuous backups using point-in-time recovery (PITR)
	- Optionally enabled for the last 35 days
	- Point-in-time revovery to any time within the backup window
	- The recovery process creates a new table
- On-demand backups:
	- Full backups for long-term retention, until explicitely deleted
	- Doesn't affect performance or latency
	- Can be configured and managed in AWS Backup (enables cross-region copy)
	- The recovery process creates a new table

### Integration with S3
- Export to S3 (must enable PITR)
	- Works for any point of time in the last 35 days
	- Doesn't affect the read capacity of your table
	- Performa data analysis on top of DynamoDB
	- Retain snapshots for auditing
	- ETL on top of S3 data before imnporting back into DynamoDB
	- Export in Dybamo JSON or ION format
- Import to S3
	- Import CSV, DynamoDB JOSN or ION  format
	- Doesn't consume any write capacity
	- Creates a new table
	- Import errors are logged in CloudWatch


## API Gateway
- Combining it with Lambda, you can have a full serverless application, with no infrastructure to manage
- Support for WebSocket protocol
- Handle API versioning
- handle different environments (dev, test, prod)
- Handle securitt (Authentication and Authorization)
- Create API keys, handle request throttling
- Swagger/Open API import to quickly define APIs, and can also export them
- Transform and validate requests and responses
- Generate SDK and API specifications
- Cache API responses

### Integrations
- **Lambda Function**
	- Easy way to expose REST API backed by Lambda
- **HTTP**
	- Expose HTTP endopints in the backend
	- You can connect it to an internal API on premise, ALB, etc...
	- Why? Add rate limiting, caching, user authentications, API keys, etc...
- **AWS Service**
	- Expose any AWS API through the API Gateway
	- In this way we can expose a AWS service to users without giving them credentials to access them directly
	- Example: start an AWS Step Function workflow, post a message to SQS, send a message to Kinesis Data Streams

### Endpoint Types
- **Edge-Optimized (default)**
	- Requests are routed through the CloudFront Edge locations (improve latency)
	- The API Gateway still live in only one region
- **Regional**
	- For clients within the same region
	- Could manually combine with CloudFront (more control over the caching strategies and the distribution)
- **Private**
	- Can only be accessed from your VPC using an interface VPC endpoint (ENI)
	- Use a resource policy to define access

### Security
#### IAM permissions
- Create an IAM policy authorization and attach to User/Role
- API Gateway verifies IAM permissions passed by the calling application
- Good to provide access within your own infrastructure
- Leverages "Sig v4" capability where IAM credential are in headers
- Handle authentication and authorization

#### Custom Domain Name HTTPS
- Security through integration with AWS Certificate Manageer (ACM)
- If using Edge-Optimized endpoint, then the4 certificate must be in us-east-1
- If using Regional endpoint, the certificate must be in the API Gateway region
- Must setup CNAME or A-alias record in Route 53

#### Lambda  Authorizer (formerly Custom Authorizer)
- User AWS Lambda to validate the token in header being passed
- Option to cache result of authentication
- Helps to use OAuth/SAML/3rd party type of authentication
- Lambda must return an IAM policy for the user
- Handle authentication and authorization

![[api-gateway-security-lambda.png]]

#### Cognito User Pools
- Cognito fully manages user lifecycle
- API gateway verifies identity automatically from AWS Cognito
- No custom implementation required
- Cognito only helps with authentication, not authorization

![[api-gateway-security-cognito.png]]


## Cognito
- Give users an identity so that they can interact with our application
- **Cognito User Pools**
	- Sign in functionality for app users
	- Integrate with API Gateway and Application Load Balancer
- **Cognito Identity Pools (Federated Identity)**
	- Provide AWS credentials to users so they can access AWS resources directly
	- Integrate with Cognito User Pools as an identity provider
- **Cognito Sync**
	- Syncronize data from device to Cognito
	- May be deprecated and replaced by AppSync

### Cognito User Pools (CUP)
- Create a serverless database of users for your web and mobile apps
- Simple login: Username (or email) / password combination
- Possibility to verify emails/phone numbers and add MFA
- Can enable Federated Identities (Facebook, Google, SAML) (different from Identity pools)
- Sends back a JSON Web Token (JWT)
- Can be integrated with API Gateway and ALB for authentication

### Federated Identity Pools
It provides direct access to AWS Resources from the Client Side by:
- Log in to federated identity provider, or remain anonymous
- Get temporary AWS credentials back from the Federated Identity Pool
- These credentials come with a pre-defined IAM policy stating their permissions
- Example: provide temporary access to write directly to S3 bucket using Facebook Login

![[federated-identity-pools-workflow.png]]


## Step Functions
- Vuild serverless visual workflow to orchestrate your Lambda functions
- Features: sequence, parallel, conditions, timeouts, error handling, ...
- Can integrate with EC2, ECS, on-premises servers, API Gateway, SQS, etc...
- Possibility of implementing human approval feature
- Use cases: order fulfillment, data processing, web applications, any workflow

## SAM - Serverless Application Model
- Framework for developing and deploying serverless applications
- All the configuration is YAML code
- SAM can help you to run Lambda, API Gateway, DynamoDB locally
- SAM can use CodeDeploy to deploy Lambda functions
