# EC2 Instance Storage

## EBS Volume
- EBS (Elastic Block Store) Volume is a network drive you can attach to rou instances while they run
	- it can be detached from an EC2 instance and attached to another one quickly
- It allows instances to persist data, even after their termination
- They can only be mounted to one instance at a time
- They are bound to a specific AZ
	- An EBS Volume in us-east-1a cannot be attached to us-east-1b
	- To move a volum across different AZs, you first need to snapshot it
- It has a provisioned capacity (size in GB and IOPS)
	- You get billed based on the provisioned capacity
	- You can increase the capacity of the drive over time
- You can choose in the setting whether the EBS volume has to be terminated when the EC2 instance is terminated or not (by default EBS volume is not terminated)

### Volume Types
There are 6 types:
- **gp2/gp3 (SSD)**: General purpose SSD volume that balances price and performance for a wide variety of workloads. In gp3 you can increase size and IOPS independently, instead in gp2 they are linked together
- **io1/io2 (SSD)**: Highest performance SSD volume for mission-critical low-latency or high-throughput workloads
- **st1 (HDD)**: Low cost HDD volume designed for frequently accessed, throughput-intensive workloads
- **sc1 (HDD)**: Lowest cost HDD volume designed for less frequently accessed workloads

For EC2 instances, only gp2, gp3, io1 and io2 can be used as root volume

### EBS Multi-Attach
- Only if the volume is io1 or io2
- The EC2 instances must be in the same AZ
- Each instance has full read and write permissions to the volume
- Must use a file system that's cluster-aware (not XFS, EX4, etc...)
- Use Cases:
	- Achieve higher application availability in clustered Linux applications
	- Applications must manage concurrent write operations


### EBS Snapshot
- Make a backup (snapshot) of your EBS volume at a point in time
- Not necessary to detach volume to do snapshot, but recommended
- Can copy snapshots across AZ or region

![[ebs-snapshot.png]]

#### Snapshot Archive
- Move a Snapshot to an "archive tier" that is 75% cheaper
- Takes within 24 to 72 hours for restoring the archive

#### Snapshot Recycle Bin
- Setup rules to retain deleted snapshots so you can recover them after an accidental deletion
- Specify retention (from 1 day to 1 year)

### EBS Encryption
When you created an encrypted EBS volume, you get the following:
- Data at rest is encrypted inside the volume
- All the data moving between the instance and the volume is encrypted
- All snapshots are encrypted
- All volumes created from snapshot are encrypted
- Encryption and decryption is done behind the scenes automatically, so you have to do nothing
- Encryption has minimal impact on latency
- EBS use AWS KMS for encryption keys
- Snapshots of encrypted volumes are encrypted

#### How to encrypt an unencrypted EBS volume
- Create an EBS snapshot of the volume
- Encrypt the EBS snapshot using copy
- Create new ebs volume from the snapshot (the volume will also be encrypted)
- Now you ca attach the encrypted volume to the original instance

## AMI
- AMI = Amazon Machine Image
- AMI are a customization of an EC2 instance
	- You add your own software, configuration, operating system, monitoring, etc...
	- Faster boot/ configuration time because all your software is pre-packaged
- AMI are built for a specific region and can be copied across regions
- You can launch EC2 instances from:
	- **A Public AMI**: AWS provided
	- **Your own AMI**: you make and maintain them yourself
	- **An AWS Marketplace AMI**: an AMI someone else made (and potentially sells)

### AMI process
- Start an EC2 instance and customize it
- Stop the instance (for data integrity)
- Build an AMI (this will also create EBS snapshots) from that instance
- Launch new instances with the AMI you just created

## EC2 Instance Store
- It's a high performance hardware disk, faster then EBS volumes
- They have very high IOPS
- EC2 Instance Store lose their storage if they're stopped
- Good for buffer / cache / scratch data / temporary content
- Risk of data loss if hardware fails
- Backups and Replication are your responsibility

## EFS - Elastic File System
- Managed NFS (network file system) that can be mounted on many EC2
- EFS works with EC2 instances in multi-AZ
- Highly available, scalable, expensive (3 times the price of gp2), pay per use
- Useful for content management, web serving, data sharing
- Uses NFSv4.1 protocol
- Uses security group to control access
- Compatible only with Linux based AMI (not Windows)
- Encryption at rest using KMS
- POSIX file system that has a standard file API
- File system scales automatically, no need of capacity planning

### EFS Performance
##### EFS Scale
- You can get 1000s of concurrent NFS clients, 10 GB+/s throughput
- Can grow to petabyte-scale network file system automatically

##### Performance mode (set at creation time)
- General purpose (default): latency-sensitive use cases (web server, CMS, etc...)
- Max I/O: higher latency and throughput, highly parallel (big data, media processing)

##### Throughput mode
- Bursting: 1 TB = 50 MiB/s + burst of up to 100 MiB/s (increases with file system size)
- Provisioned: set your throughput regardless of storage size

### EFS Storage Classes
##### Storage Tiers (lifecycle management feature - move file after N days)
- Standard: for frequently accessed files
- Infrequent access (EFS-IA): cost to retrieve files, lower price to store. You can enable IA with a Lifecycle Policy, for example to move into this storage class the files not accessed for a certain period of time

##### Availability and durability
- Standard: multi-AZ, great for prod
- One Zone: one AZ, great for dev, backup enabled by default, compatible with IA, 90% in cost saving
