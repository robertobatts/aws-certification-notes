## Well Architected Framework General Guiding Principles
- Stop guessing your capacity needs
- Test systems at production scale
- Automate to make architectural experimentation easier
- Allow for evolutionary architectures, design based on changing requirements
- Drive architectures using data

### 6 Pillars
1. Operational Excellence
2. Security
3. Reliability
4. Performance Efficiency
5. Cost Optimization
6. Sustainability

### AWS Well-Architected Tool
- Free tool to review your architectures against the 6 pillars and adopt architectural best practices
- How it works:
	- Select your workload and answer questions
	- Review your ansers against the 6 pillars
	- Obtain advice: get videos and documentations, generate a report, see the results in a dashboard


## Trusted Advisor
- No need to install anything, high level AWS account assessment
- Analyze your AWS accounts and provides recommendations for cost optimization, performance, security, fault tolerance and service limits
- Cn enable weekly email notifications from the console
- There are different tiers:
	- Core checks and recommendations - all customers
	- Full Trusted Advisor - available for Business and Enterprise support plans
		- You can set CloudWatch alarms on service limits
		- You have programmatic access to AWS Support API

### Checks Examples
- Cost Optimization:
	- low utilization of EC2 instances, idle load balancers, under-utilizied EBS volumes...
	- Reserved instances and savings plans optimizations
- Performance:
	- High utilization of EC2 instances, CloudFront CDN optimizations
	- EC2 to EBS throughput optimizations, Alias records recommendations
- Security:
	- MFA enabled on Root Account, IAM key rotation, exposed Access Keys
	- S3 Bucket Permissions for public access, security groups with unrestricted ports
- Fault Tolerance:
	- EBS snapshots age, Availability Zone Balance
	- ASG Multi-AZ, RDS Multi-AZ, ELB configuration...
- Service Limits:
	- Information about wheather your reaching the service limits for a particular service

## Architecture Examples:
- https://aws.amazon.com/architecture/
- https://aws.amazon.com/solutions/
