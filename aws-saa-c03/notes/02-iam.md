# IAM
- IAM doesn't require region selection 
- **Root account** created by default should not be used or shared
- **Users** are people within your organization, they can be grouped
- **Groups** can only contain users, not other groups
- A user can belong to zero, one or multiple groups

## IAM Permissions
- Users or groups can be assigned **policies** as JSON documents
- These policies define the **permissions** of the users
- In AWS you apply the **least privilege principle**, you don't give more permissions than a user needs

## IAM Policies Structure
![[iam-policy.png]]
Consists of:
- Version
- Id (optional), an identifier of the policy
- Statement, they conists of: 
	- Sid (optional), an identifier of the statement
	- Effect, whether the statements allors or denies acces (Allow, Deny)
	- Principal, account/user/role which this policy is applied to
	- Action, list of actions this policy allows or denies
	- Resource, list of resources to which actions are applied to
	- Condition (optional) for when this policy is in effect

## IAM Password Policy
In AWS you can set up a password policy, requiring a user to have a minimum length or a specific set of characters.
You can also set MFA (Multi Factor Authentication). The options for MFA devices are:
- Virtual device (Google Authenticator, Authy)
- Universal 2nd Factor Authenticator (Yubikey)
- Hardware Key Fob Device

### How to activate MFA?
Click to the account username on the top right, then Security Credentials > Multi-factor Authentication > Activate MFA, and choose the authentication type from there.

## IAM Roles for Services
Roles are used to give AWS Services permissions to do actions on your behalf. For example, an application deployed in a EC2 instance might want to upload something on S3, this action has to be allowed through Roles.

## IAM Security Tools
- **Credentials Report** (account-level): a report that lists all your account's users and the status of their cedentials
- **Access Advisor** (user-level): it shows the service permissions granted to a user and when those services were last accessed

## IAM Guidelines & Best Practices
- Don't use root account except for AWS account setup
- Create a IAM User for each person who needs to access your account
- Assign users to groups and assign permissions to groups
- Create a strong password policy
- Use and enforce MFA
- Create and use Roles to give permissions to AWS Services
- Use Access Keys for programmatic access (CLI/SDK)
- Audit permissions of your account with IAM Credentials Report
- Never share IAM users and Access Keys
