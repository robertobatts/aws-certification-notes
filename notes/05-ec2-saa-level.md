# AWS EC2 Solutions Architect Associate Level

## Elastic IPs
- When you stop an EC2 instance, it changes its public IP. If you need to have a fixed public IP for your instance, you need an Elastic IP
- An Elastic IP is a public IPv4 you own as long as you don't delete it
- You can attach it to one instance at a time
- You can only have 5 Elastic IPs in your account

Overall you should try to avoid using Elastic IP:
- They often reflect poor architectural decisions
- Instead, use a random public IP and register a DNS name to it
- Or use a Load Balancer

## Placement Groups
Sometimes you want to have control over the EC2 Instance placement strategy. Thisn strategy can be defined using placement groups
When you create a group, you can specify one of the following strategies:
- **Cluster** - clusters instances into a low-latency group in a single AV
- **Spread** - spreads instances across underlyng hardware (max 7 instances per group per AZ)
- **Partition** - spreads instances across many different partitions (which rely on differet sets of racks) within an AZ. Scales to 100s of EC2 instances per group

### Cluster
**Pros**
- Great network (10 Gbps bandwith between instances)
**Cons**
- If the rack fails, all instances fails at the same time
**Use Case**
- Big Data job that needs to complete fast
- Application that needs extremely low latency and high network throughput

![[placement-group-cluster.png]]

### Spreads
**Pros**
- Can span across different AVs
- Reduced risk of simultaneous failure
- EC2 Instances are on different physical hardware
**Cons**
- Limited to 7 instances per AZ per placement group
**Use Case**
- Application that needs to maximize high availbility
- Critical applications where each instance must be isolated from failure from each other

![[placement-group-spread.png]]

### Partition
**Pros**
- Each partition is isolated from falure, because every partition has its own rack
- Can span across multiple AZs in the same region
**Cons**
- Up to 7 partitions per AZ
- A partition failure will still affect multiple instances at the same time
**Use Case**
- Application that has to be partition aware to distribute data, so big data application like Cassandra or Kafka

![[placement-group-partition.png]]

## Elastic Network Interfaces (ENI)
It's a logical component in a VP that represents a **virtual network card**. They can have the following attributes:
- Primary private IPv4
- One or more secondary IPv4
- One Elastic IPv4 per private IPv4
- One public IPv4
- One or more security groups
- MAC address

ENI can be created independently and be attached to EC2 instances, or moved from an instance to another. For example, if a private IP is attached to an instance this instance has failure, the ENI of that IP can be moved to a working instance, therefore the requests on that same IP will start to work again.
ENIs are bound to a specific AV.
To know more about ENI, read the following blog https://aws.amazon.com/blogs/aws/new-elastic-network-interfaces-in-the-virtual-private-cloud/

## EC2 Hibernate
- The in-memory (RAM) state is preserved
- The instance boot is much faster
- Under the hood the RAM state is written to a file in the root EBS volume
- The root EBS volume must be encrypted

**Use Case**
- Long running processing
- Saving the RAM state
- Services that take time to initialize

### Good to Know
- **Supported Instance Families** - C3, C4, C5, I3, M3, M4, R3, R4, T2, T3
- **Instance RAM Size** - must be less than 150 GB
- **Instance Size** - not supported for bare metal instances
- **AMI** - Amazon Linux 2, Linux AMI, Ubuntu, RHEL, CentOS and Windows
- **Root Volume** - must be EBS encrypted, not instance store, and large enough to contain the RAM
- Available for On-Demand, Reserved and Spot instances
- An instance cannot be hibernated for more than 60 days

## EC2 Nitro
- Underlying Platform for the next generation of EC2 instances
- New virtualization technology
- Better networking options (enhanced networking, HPC, IPv6)
- Higher Speed EBS
- Better underlying security

## Understanding vCPU
- Multiple threads can run on one CPU
- Each thread is represented as a virtual CPU (vCPU)
- For example, m5.2xlarge has 4 CPU and 2 threads per CPU, that is equal to 8 vCPU

### Optimizing CPU options
In some cases you may want to change the vCPU options of an instance during its launch:
- **# of CPU cores**: you can decrease it to decrease licensing cost, helpful if you need the high RAM of that machine but don't need the default amount of CPU provided
- **# of threads per core**: disable multithreading to have 1 thread per CPU, helpful for high performance computing workloads

## Capacity Reservations
- Ensure you have compute capacity when needed
- Manual or planned end date for the reservation
- No need for 1 or 3 year commitment
- Capacity access is immediate, you get billed as soon as it starts
- You can specify:
	- AV in which to reserve the capacity (only one)
	- Number of instances for which to reserve capacity
	- The instance attributes, including the instance type, tenancy and OS
- Combine with Reserved instances and Saving Plans to cut costs