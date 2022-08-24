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

## DynamoDB
- Fully managed, highly available with replication across multiple AZs
- NoSQL database
- Scales to massive workloads, distributed database
- Millions of requests per seconds, trillions of row, 100s of TB of storage
- Fast and consistent performance
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
	- Sent to Kinesis Data Streams
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

### Indexes
- Global Secondary Indexes (GSI) and Local Secondary Indexes (LSI)
- Allow to query on attributes other than the Primary Key

### Transactions
- Allow you to write to two tables at the same time, or to none of them


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
- **AWS Service**
	- Expose any AWS API through the API Gateway
	- Example: start an AWS Step Function workflow, post a message to SQS

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
- Create an IAM policy authorization and attach to User/ROle
- API Gateway verifies IAM permissions passed by the calling application
- Good to provide access within your own infrastructure
- Leverages "Sig v4" capability where IAM credential are in headers
- Handle authentication and authorization

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
	- Integrate with API Gateway
- **Cognito Identity Pools (Federated Identity)**
	- Provide AWS credentials to users so they can access AWS resources directly
	- Integrate with Cognito User Pools as an identity provider
- **Cognito Sync**
	- Syncronize data from device to Cognito
	- May be deprecated and replaced by AppSync

### Cognito User Pools (CUP)
- Create a serverless database of users for your mobile apps
- Simple login: Username (or email) / password combination
- Possibility to verify emails/phone numbers and add MFA
- Can enable Federated Identities (Facebook, Google, SAML) (different from Identity pools)
- Sends back a JSON Web Token (JWT)
- Can be integrated with API Gateway for authentication

### Federated Identity Pools
It provides direct access to AWS Resources from the Client Side by:
- Log in to federated identity provider, or remain anonymous
- Get temporary AWS credentials back from the Federated Identity Pool
- These credentials come with a pre-defined IAM policy stating their permissions
- Example: provide temporary access to write directly to S3 bucket using Facebook Login

![[federated-identity-pools-workflow.png]]

### Cognito Sync
- Deprecated - use AWS AppSync now
- Store preferences, configuration, state of app
- Cross device synchronization (any platform, iOS, Android, etc...)
- Offline capability (synchronization when back online)
- Requires Federated Identity Pool in Cognito (not User Pool)
- Store data in datasets (up to 1MB)
- Up to 20 datasets to synchronise

## SAM - Serverless Application Model
- Framework for developing and deploying serverless applications
- All the configuration is YAML code
- SAM can help you to run Lambda, API Gateway, DynamoDB locally
- SAM can use CodeDeploy to deploy Lambda functions
