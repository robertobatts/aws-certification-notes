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

