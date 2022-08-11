# AWS EC2 Fundamentals
- EC2 = Elastic Comput Cloud
- It's an Infrastracture as a Service, and it's one of the most popular services in AWS
- It allows:
	- Renting virtual machines (EC2)
	- Storing data on virtual drives (EBS)
	- Distributing load across machines (ELB)
	- Scaling services using an auto-scaling group (ASG)

## Sizing and Configuration options
- OS: Linus, Windows or MacOS
- CPU
- RAM
- Storage space:
	- Network-attached (EBS and EFS)
	- Hardware (EC2 Instance Store)
- Network card
- Firewall rules
- Bootstrap script (EC2 User data)

## User Data
- It allows to launch a script in your EC2 machines when they start
- This script is run only once at the first instance start
- It's used to automate boot tasks such as:
	- Installing updates
	- Installing software
	- Downloading common files
A simple example of EC2 User Data script can be found in [ec2-user-data.sh](../code/ec2-user-data.sh)

## Instance Types
All the AWS Instance Types are listed here https://aws.amazon.com/ec2/instance-types/. You can instead use https://instances.vantage.sh/ to compare all their features and their prices.

They have the following naming convention:
**m5.2xlarge**
- **m**: instance class
- **5**: generation
- **2xlarge**: size within the instance class

The instance types can be grouped by the following use cases:

#### General Purpose
- Great diversity of workloads, such as web servers or code repositories
- Balance between Compute, Memory and Networking

#### Compute Optimized
Great for compute-intensive tasks that require high performance processors, such as:
- Batch processing workloads
- High performance web servers
- High performance computing (HPC)
- Scientific modeling and machine learning 
- Dedicated gaming servers

#### Memory optimized
Great for workloads that processes large data sets in memory. Possible use cases are:
- High performance relational/non-relational databases
- Distributed web scale cache stores
- In memory databases optimized for BI
- Applications performing real-time processing of big unstructured data

#### Storage Optimized
Great for storage-intensive tasks that require high, sequential read and write access to large data sets on local storage. Possible use cases are:
- High frequency online transaction processing (OLTP) systems
- Relational and NoSQL databases
- Cache for in-memory databases (for example Redis)
- Data warehousing applications
- Distributed fyle systems

## Security Groups
Security groups act as a firewall on EC2 instances. They regulate:
- Access to ports
- Authorised IP ranges - IPv4 and IPv6
- Control of inbound network
- Control of outbound network

#### Good to know
- One security group can be attached to multiple instances
- Locked down to a region/VPC combination
- It lives outside the EC2, if traffic is blocked by a security group, the EC2 instance won't see it
- It's good to mantain a separate security group for SSH
- If your app is not acessible (timeout error), then it's a security group issue
- If your app gives a "connection refused" error, then it's an application error, or it's not launched
- All inbound traffic is blocked by default
- All outbound traffic is authorised by default

#### Referencing other security groups
If two instances have the same security group attached, they have automatically inbound access allowed for each other
![[security-groups-ref.png]]

#### Ports to know
- 22 = SSH (Secure Shell), log into a Linux instance
- 21 = FTP (File Transfer Protocol), upload files into a file share
- 22 = SFTP (Secure File Transfer Protocol), upload files using SSH
- 80 = HTTP, access unsecured websites
- 443 = HTTPS, access secured websites
- 3389 = RDP (Remote Desktop Protocol), log into a Windows instance


## How to access an instance using SSH
The first time you use your pem key, run the following command to restrict permissions on the key:
``` bash
chmod 0400 <pem_file>
```
Then you can normally run the following command to connect:
``` bash
ssh -i <pem_file> ec2-user@<public_ip>
```

## Use AWS CLI from an EC2 Instance
EC2 instances have AWS CLI automatically installed. If you try to use the aws command you will be asked to run `aws configure` and insert your credentials. This is a bad a idea and should not be done, because then everyone who has access to the EC2 instance gains acess to our credentials too.
Instead, you should create an AWS Role for it. After doing this, you will be able to run the AWS CLI from the EC2 Instance without using your credentials.

## EC2 Purchasing Options
- On-Demand Instances - short workload, predictable pricing, pay by second
- Reserved (1 and 3 years) - long workloads
- Convertible Reserved Instances - long workloads with flexible instances
- Saving Plans (1 and 3 years) - commitment to an amount of usage, long workload
- Spot Instances - short workloads, cheap, can lose instances (less reliable)
- Dedicated Hosts - book an entire physical server, control instance placement
- Dedicated Instances - no other customer will share your hardware
- Capacity Reservations - reserve capacity in a specific AZ for any duration

### EC2 On-Demand Instances
- Pay for what you use
- Highest cost, but no upfront payment
- No long-term commitment
- Recommended for short-term and uninterrupted workloads, where you can't predict how the application will behave

### EC2 Reserved Instances
- Up to 72% discount compared to On-Demand
- You reserve a specific instance attribute (Instance Type, Region, Tenancy, OS)
- Reservation Period (1 or 3 years)
- Payment Options - No Upfront, Partial Upfront, All Upfront (greater discount)
- Reserved Instance's Scope - Regional or Zonal (reserve capacity in an AZ)
- Recommended for steady-state usage applications (e.g. database)
- You can buy and sell in the Reserved Instance Marketplace

#### EC2 Convertible Reserved Instances
- Can change the EC2 instance tpye, instance family, OS, scope and tenancy
- Up to 66% discount

### EC2 Saving Plans Instances
- Ged a discount up to 72% based on long-term usage
- Commit to a certain type of usage (e.g. 10$/hour for 1 or 3 years)
- Usage beyond EC2 Saving Plans is billed at the On-Demand price
- Locked to a specific instance family and AWS region (e.g. M5 in us-east-1)
- Flexible for:
	- Instance Size (e.g. m5.xlarge, m5.2xlarge)
	- OS (e.g. Linux, Windows)
	- Tenancy (Host, Dedicated, Default)

### EC2 Spot Instances
- Can get a discount of up to 90% compared to On-Demand
- You can lose the instance at any time if your max price is less than the current spot price
- It's the most cost-efficient instance in AWS
- Useful for workloads that are resilient to failure

Spot instances can be one-time type or persistent. If they are one-time, once the instance is cancelled because of the price, it's not reopened. If it is persistent, when it is cancelled a Create Request gets created with the same parameters to recreate the instances when possible
![[spot-instance-onetime-vs-persistent.png]]

### EC2 Dedicated Hosts
- A physical server with EC2 instance capacity fulli dedicated to your use
- Allows you to a ddress compliance requirements in your company and use your existing server-bound software licenses
- Purchasing Options:
	- On-Demand
	- Reserved
- It's the most expensive option

### EC2 Dedicated Instances
- Instances run on hardware that is dedicated to you
- May share hardware with other instances in the same account
- No control over instance placement
![[dedicated-instance-vs-host.png]]

### EC2 Capacity Reservations
- Reserve On-Demand instances capacity in a specific AZ for any duration
- You always have access to EC2 capacity when you need it
- No time commitment (create/cancel anytime), no billing discounts
- Combine with Regional Reserved Instances and Saving Plans to benefit from billing discounts
- You're charged at On-Demand rate whether you run instances or not
- Suitable for short-term, uninterrupted workloads that needs to be in a specific AZ

### Spot Fleets
It's a set of Spot Instances + optional On-Demand Instances.
Spot Fleet will try to reach the target capacity following your price constraints:
- Define Instance Type, OS, AV
- Can have multiple launch pools, so that the fleet can choose
- It stops launching instances when reaching capacity or max cost

Strategies to allocate Spot Instances:
- **lowestPrice**: cost optimization
- **diversified**: distributed across all pool, good for availability
- **capacityOptimized**: pool with the optimal capacity for the number of instances

