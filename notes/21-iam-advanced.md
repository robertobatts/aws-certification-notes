# Identy and Access Management - Advanced

## STS - Security Token Service
- Allows to grant limited and temporary access
- Token is valid for up to one hour (must be refreshed)
- On of the most important APIs is **AssumeRole**
	- Can be done within your own account for enhanced security
	- For Cross Account Access, assume role intarget account to perform actions there
- **AssumeRoleWithSAML**
	- Return credentials for users logged with SAML
- **AssumeRoleWithWebIdentity**
	- Return credentials for users logged with an Identity provider (Facebook, Google, etc...)
	- AWS recommends against using this, and using Cognito instead
- **GetSessionToken**
	- For MFA, from a user or AWS account root user

### Using STS to Assume a Role
- Define an IAM ROle within your account or cross-account
- Defin which principals can access this IAM Role
- Use AWS STS to retrieve credentials and impersonate the IAM Role you have access to
- Temporary credentials can be valid between 15 minutes and 1 hour

## Identity Federation in AWS
- Federation lets users outside of AWS to assume temporary role for accessing AWS resources
- These users assume identity provided access role
- Federations can have many flavors:
	- SAML 2.0
	- Custom Identity Broker
	- Web Identity Federation with Amazon Cognito
	- Single  Sign On
	- Non-SAML with AWS Microsoft AD
- Using federation, you don't need to create IAM users (user management is outside of AWS)

### SAML 2.0
- Provides access to AWS Console or CLI (through temporary credentials)
- No need to create an IAM user for each of your employees
- When you access the console, you need to provide the SAML in the sign-in URL
- Needs to setup a trust between AWS IAM and SAML (both ways)
- SAML 2.0 enabled web-based, cross domain SSO
- Uses the STS API: AssumeRoleWithSAML
- Federation through SAML is the "old way" of doing thinks
- Amazon Single SIgn On (SSO) Federation is the new managed and simpler way

### Custom Identity Broker Application
- Use only if identity providerr is not compatible with SAML 2.0
- The identity broker must determine the appropriate IAM policy
- Uses the STS API: AssumeRole or GetFederationToken
- You have to write the indentity broker by yourself

### Web Identity Federation
- Not recommended by AWS, use Cognito instead (allows for anonymous users, data synchronization, MFA)
- The client get a token from the identity provider, which then exchanges with AWS STS for a token to access AWS

### Cognito
- Log in to federated identity provider, or remain anonymous
- Get temporary AWS credentials back from the Federated Identity Pool
- These credentials come with a pre-defined IAM policy stating their permissions

## Microsoft Active Directory (AD)
- Found on any Windows Server with AD Domain Services
- It's a database of objects: User Accounts, Computers, Printers, File Shares, Security Groups
- Centralized security management, create account, assign permissions
- Objects are organized in trees
- A group of trees is a forest

### AWS Directory Services
- **AWS Managed Microsft AD**
	- Create your own AD in AWS, manage users locally, supports MFA
	- Establish trust connections with your on-premise AD
- **AD Connector**
	- Directory Gateway to redirect to on-premise AD, supports MFA
	- Users a re managed on the on-premise AD 
- **Simple AD**
	- AD-compatible managed directory on AWS
	- Cannot be joined with on-premise AD

## AWS Organizations
- Global service
- Allows to manage multiple AWS accounts
- The main account is the master account
- Member accounts can only be part of one organization
- Consolidated Billing across all accounts, single payment method
- Pricing benefits from aggregated usage (volume discount for EC2, S3...)
- API is available to automate AWS account creation

### Multi Account Strategies
- Create accounts per department, per cost center, per dev/test/prod, based on regulatory restrictions (using SCP), for better resource isolation, to have separate per-account service limits, isolated account for logging
- Multi Account vs One Account Multi VPC
- Use tagging standards for billing purposes
- Enable CloudTrail on all accounts, send logs to central S3 account
- Send CloudWatch Logs to central logging account
- Establish Cross Account Roles for Admin purpose

### Organizational Units (OU) - Example

![[organization-units-example.png]]

### Service Control Policies (SCP)
- Whitelist or blacklist IAM actions
- Applied at the OU or Account level
- Does not apply to the Master Account
- SCP is applied to all the Users and Roles of the Account, including Root
- The SCP does not affect service-linked roles
	- Service-linked roles enable other AWS services to integrate with AWS Oraganizations and can't be restricted by SCPs
- SCP must have an explicit Allow (doesn't allow anything by default)
- SCP structure looks like an IAM policy
- Use cases:
	- Restrict access to certain services
	- Enforce PCI compliance by explicitly disabling services

### Moving Accounts
To migrate accounts from one organization to another:
1. Remove the member account from the old organization
2. Send an invite to the new organization
3. Accept the invite to the new organization from the member account

if you want the master account of the old organization to also join the new organization:
1. Remove the member accounts from the organizations using procedur above
2. Delete the old organization
3. Repeat the process above to invite the old master account to the new org

## IAM Permission Boundaries
- IAM Permission Boundaries are supported for users and roles (not groups)
- Advanced feature to use a managed policy to set the maximum permissions an IAM entity can get
- They specify the boundaries a IAM permission can set
- Example: if permission boundary allows only S3, and we attach a policy to use EC2 for a user, the policy won't work because it's outside of the boundary
- Use case: allow developers to self-assign policies and manage their own permissions, while making sure they can't excalate their priviles (= make themselves admin)

## IAM Policy Evaluation Policy

![[policy-evaluation-logic.png]]

## Resource Access Manager (RAM)
- Share AWS resources that you own with other AWS accounts
- Share with any account or within your Organization
- Avoid resource duplication
- VPC Subnets:
	- allow to have all the resources launched in the same subnets
	- must be from the same AWS Organizations
	- cannot share security groups and default VPC
	- participants can manage their own resources in there
	- participants can't view, modify, delete resources that belong to other participants or the owner
- AWS Transit Gateway
- Route53 Resolver Rules
- License Manager Configurations

## AWS Single Sign On (SSO)
- The new version of this is called **AWS IAM Identity Center**
- Centrally manage Single Sign On to access multiple accounts and 3rd party business applications
- Integrated with AWS Organizations
- Supports SAML 2.0 markup
- Integration with on-premise Active Directory
- Centralized permission management
- Centralize auditing with CloudTrail

## 3rd party SAML vs AWS SSO

![[saml-3rd-party-vs-aws-sso.png]]
