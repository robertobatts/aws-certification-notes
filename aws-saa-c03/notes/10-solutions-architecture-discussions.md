# Classic Solutions Architecture Discussions

## WhatIsTheTime.com
### Requirements
- WhatIsTheTime.com allows people to know what time it is
- We don't need a database
- We want to scale horizontally, no downtime

### Solution
![[what-is-the-time-com-architecture.png]]


## MyClothes.com
### Requirements
- MyClothes.com allows people to buy clothes online
- There's  a shopping cart
- Our website is having hunderds of users at the same time
- We need to scale, maintain horizontal scalability and keep our web application as stateless as possible
- Users should their details in a database

### Solution
![[my-clothes-com-architecture.png]]


## MyWordpress.com
### Requirements
- We want to create a fully scalable WordPress website
- We want this website to access and correctly display picture uploads
- Our user data and the blog content should be store in a MySQL database

### Solution
![[my-wordpress-com-architecture.png]]


## Instantiating applications quickly
- EC2 Instances:
	- **Use a Gloden AMI**: install your applications, OS dependencies, etc... beforehand and launch your EC2 instance from the Golden AMI
	- **Bootstrap using User Data**: for dynamic configuration
	- **Hybrid**: mix of Golden AMI and User Data (Elastic Beanstalk)
- RDS Databases:
	- Restore from a snapshot, so that the db will have schemas and data ready
- EBS Volumes:
	- Restore from a snapshot so that the disk will already be formatted and have data


## Elastic Beanstalk
- It's a developer centric view of deploying an application on AWS
- It uses all the components we've sen before: EC2, ASG, ELB, RDS, ETC...
- Automatically handles capacity provisioning, load balancing, scaling, application health monitoring, instance configuration
- Your only responsibility is the application code
- You still have full control over the configuration
- Beanstalk is free but you pay for the underlying instances

### Components
- **Application**: collection of Elastic Beanstalk components (environements, versions, configurations, etc...)
- **Application Version**: an iteration of your application code
- **Environement**:
	- Collection of AWS resources running an application version (only one application version at a time)
	- **Tiers**: Web Servire Environment Tier and Worker Environment Tier
	- You can create multiple environments (dev, test, prod, etc...)

### Web Server Tier vs Worker Tier
![[elastic-beanstalk-tiers.png]]
