
## CloudFormation
- Declaritive way of outlining your AWS infrastructure for any resources (most of them are supported)
- For example, within a CloudFormation template, you can say:
	- I want a security group
	- I want two EC2 instances using this security group
- Then CloudFormation creates those for you, in the right order, with the exact configuration that you specified

#### Benefits
- Infrastructure as code, you don't have to create resources manually
- Changes to infrastructure can be reviewed by code
- Cost
	- Each resources within the stack is tagged with an identifier so you can easily see how much a stack cost you
	- You can estimate the costs of your resources using the CloudFormation template
- Savings strategy: e.g. in Dev you could automate deletion of templates at 5pm and recreate it at 8am
- Productivity
	- Ability to destroy and re-create an infrastructure on the cloud on the fly
	- Automated generation of Diagram for your templates
	- Declarative programming (no need to figure out ordering and orchestration)
- Don't re-invent the wheel, leverage existing templates on the web
- Supports almost all AWS resources
- You can use "custom resources" for resources that are not supported

## Simple Email Service (SES)
- Fully managed service to send emails securely, globally and at scale
- Allows inbound/outbound emails
- Reputation dashboard, performance insights, anti-spam feedback
- Provides statistics such as email deliveries, bounces, feedback loop results, email open
- Supports DomainKeys Indentified Mail (DKIM) and Sender Policy Framework (SPF)
- Flexible IP deployment: shared, dedicated and customer-owned IPs
- Send emails using your application using AWS Console, APIs or SMTP
- Use cases: transactional, marketing and bulk email communications

## Amazon Pinpoint
- Scalable 2-way (outbound/inbound) marketing communications service
- Supports email, SMS, push, voice and in-app messaging
- Ability to segment and personalize messages with the right content to customers
- Possibility to receive replies
- Scales to billions of messages per day
- Use cases: run campaigns by sending marketing, bulk, transactional SMS messages
- You can stream events (TEXT_SUCCESS, TEXT_DELIVERED, etc...) to SNS, Kinesis Data Firehose and CloudWatch Logs
- Difference with SNS and SES:
	- In SNS and SES you have to manage each message's audience, content and delivery schedule
	- In Pinpoint you create message templates, delivery schedules, highly targeted segments, and full campaigns. All of this is fully managed by Pinpoint

## SSM Session Manager
- Allows you to start a secure shell on your EC2 and on-premises servers
- No need of SSH access, bastion hosts or SSH keys
- Port 22 can be closed in security groups (better security)
- You only need to create a role attached to EC2 to allow the instance to talk to SSM service
- Send session log data to S3 or CloudWatch logs

## SSM Run Command
- Execute a script or just run a command
- Run command across multiple instances using resource groups
- No need for SSH
- Command Output can be shown in S3 or CloudWatch logs
- Send notifications to SNS about command status (In progress, Success, Failed, etc...)
- Integrated with IAM and CloudTrail
- Can be invoked using EventBridge

## SSM Patch Manager
- Automates the process of patching manged instances
- OS updates, applications updates, security updates
- Supports EC2 instances and on-premises servers
- Supports Linux, macOS and Windows
- Patch on-demand or on a schedule using Maintenance Windows
	- Defines a schedule for when to perform actions on your instances
	- Contains: Schedule, Duration, Set of registered instances, Set of registered tasks
- Scan instances and generate patch compliance report (missing patches)

## SSM Automation
- Simplifies common maintenance and deployment tasks of EC2 instances and other AWS resources
- Example: restart instances, create an AMI, create EBS Snapshot
- **Automation Runbook**: SSM Documents to define actions performed on your EC2 instances or AWS resources (pre-defined or custom)
- Can be triggered using:
	- AWS Console, AWS CLI or SDK
	- EventBridge
	- On a schedule using Maintenance Windows
	- By AWS Config for rules remediations

## Cost Explorer
- Visualize, understand and manage your AWS costs and usage over time
- Create custom reports that analyze cost and usage data
- Analyze your data at a high level: total costs and usage across all accounts
- You can set Monthly, hourly or resource level granularity
- Choose an optimal Savings Plan
- Forecast usage up to 12 months based on previous usage

## Elastic Transcoder
- Convert media files stored in S3 into media files in the formats required by consumer playback devices (phones etc...)
- Put your objects in a bucket, the Transcoding Pipeline will pick them out and convert them into a second bucket. The last bucket is the one that will be used by users
- Benefits:
	- Easy to use
	- Highly scalable
	- Cost effective, pay for what you use
	- Fully managed and secure

## AWS Batch
- Fully managed batch processing at any scale
- Efficiently run 100,000s of computing batch jobs on AWS
- Batch will dynamically launch EC2 instances or Spot instances
- It provisions the right amount of compute/memory
- You just submit or schedule batch jobs in to the batch queue, and AWS Batch does the rest
- Batch jobs are defined as Docker images and run on ECS
- Helpful for cost optimizations and focusing less on the infrastructure

## AppFlow
- Fully managed integration service that enables you to securely transfer data between SaaS applications and AWS
- Sources: Salesforce, SAP, Zendesk, Slack and ServiceNow
- Destinations: S3, Redshift or non-AWS targets such as SnowFlake and Salesforce
- Frequency: on a schedule, in response to events or on demand
- Data transformation capabilities like filtering and validation
- Encrypted over the public internet or privately over AWS PrivateLink