# AWS Storage Extras

## Snow Family
- Highly secure, portable devices to collect and process data at the edge and migrate data into and out of AWS
- Data migration: Snowcone, Snowball Edge, Snowmobile
- Edge computing: Snowcone, Snowball Edge
- They are offline devices that allow you to perform data migrations. AWS will send you a physical device, and then you will send it back after loading the data in it
- As a rule of thumb, If it takes more than a week to transfer over the network, you should use Snowball devices

### Snowball Edge
- Physical data transport solution, move TBs or PBs of data in or out of AWS
- Alternative to moving data over the network (and paying network fees)
- Pay per data transfer job
- Provide block storage and Amazon S3-compatible object storage
- **Snowball Edge Storage Optimized**
	- 80 TB of HDD capacity for block volume and S3 compatible object storage
	- It's possible to cluster up to 15 snowball edge devices
- **Snowball Edge Compute Optimized**
	- 42 TB of HDD capacity for block volume and S3 compatible object storage
- Use case: large data cloud migrations, data center decommission, disaster recovery

### Snowcone
- Small, portable computing, anywhere, rugged and secure, withstands harsh environments
- Device used for edge computing, storage, end data transfer
- 8 TB of usable storage
- Use Snowcone where Snowball doesn't fit (space-constrained environment)
- Must provide your own battery/cables
- Can be sent back to AWS offline, or connect it to internet and use AWS DataSyc to sed data

### Snowmobile
- It's an actual truck
- Transfer exabytes of data (1 EB = 1,000 PB = 1,000,000 TB)
- Each Snowmobile has 100 PB of capacity, but you can use more in parallel
- High security, temperature controlled, GPS, 24/7 video surveillance
- Better than Snowball if you transfer more than 10 PB

### Usage Process
1. Request Snowball devices from the AWS console for delivery
2. Install the  snowball client / AWS OpsHub on your servers
3. Connect the snowball to your servers and copy files using the client
4. Ship back the device
5. Data will be loaded into an S3 bucket
6. Snowball is completely wiped

### Edge Computing
Another use case for using Snow family is edge computing
- Process data while it's being created on an edge location
- These location may have limited or no internet access, and limited or no easy access to computing power
- You can use Snowball Edge or Snowcone to do edge computing
- **Snowcone**
	- 2 CPUs, 4GB of memory, wired or wireless access
	- USB-C power using a cord or the optional battery
- **Snowball Edge - Compute optimized**
	- 52 vCPIs, 208 GiB of RAM
	- Optional GPU
	- 42 TB usable storage
- **Snowball Edge - Storage Optimized**
	- Up to 40vCPUs, 80 GiB of RAM
	- Object storage clustering available
- All: Can run EC2 instances and AWS Lambda functions using AWS IoT Greengrass
- Long-germ deployment options: 1 and 3 years discounted pricing

### OpsHub
- Historically you had to uce a CLI to use Snow devices
- AWS OpsHub (software to install in your laptop) gives you a UI to manage your Snow devices
- Unlock and configure single or clustered devices
- Transfer files
- Launch and manage instances running on snow devices
- Monitor device metrics (storage capacity, active instances on your device)
- Launch compatible AWS services on your device (e.g. EC2, DataSync, NFS)

### Import data from Snowball into Glacier
- Snowball cannot import to Glacier directly
- You must use S3 first, in combination with a lifecycle policy to transition the data to Glacier

## FSx
- Launch 3rd party high-performance file systems on AWS
- Fully managed service

### FSx for Windows File Server
- It's a fully managed Windows file system share drive
- Support SMB protocol and Windows NTFS
- Microsoft Active Directory integration, ACLs, user quotas
- Can be mounted on Linux EC2 instances
- Scale up to 10s of GB/s, millions of IOPS, 100s PB of data
- Storage options:
	- SSD - latency sensitive workloads
	- HDD - broad spectrum of workloads
- Can be accessed from your on-premises infrastructure (VPN or Direct Connect)
- Can be configured to be Multi-AZ
- Data is backed-up daily to S3 for disaster recovery

### FSx for Lustre
- Lustre is a parallel distributed file system for large scale computing
- The name Lustre is derived from Linux and cluster
- Useful for machine learning and high performance computing (HPC), such as video processing, financial modeling, electronic design automation
- Scales up to 100s GB/s, mi;llions of IOPS, sub-ms latencies
- Storage Options:
	- SSD - low latency, IOPS intensive workloads, small and random file operations
	- HDD - throughput-intensive workloads, large and sequential file operations
- Seamless integration with S3
	- Can read S3 as a file system
	- Can write the output of the computations back to S3
- Can be used from on-premises servers (VPN or Direct Connect)

### FSx File System Deployment Options
- **Scratch File System**
	- Temporary storage
	- Data is not replicated (doesn't persist if file server fails)
	- High burst (6x faster, 200MBps per TiB)
	- Usage: short term processing, optimize costs
- **Persistent File System**
	- Long term storage
	- Data is replicated within same AZ
	- Replace failed files within minutes
	- Usage: long term processing, sensitive data

### Fsx for NetApp ONTAP
- Managed NetApp ONTAP on AWS
- File System compatible with NFS, SMB, iSCSI protocol
- Move worloads running on ONTAP or NAS to AWS
- Works with: Linux, Windows, MacOS, VMware Cloud on AWS, EC2, ECS, EKS
- Storage shrinks or grows automatically
- Snapshots, replication, low-cost, compression and data de-duplication

### FSx for OpenZFS
- Managed OpenZFS file system on AWS
- File System compatible with NFS (v3, v4, v4.1, v4.2)
- Move workloads running on ZFS to AWS
- Works with: Linux, Windows, MacOS, VMware Cloud on AWS, EC2, ECS, EKS
- Up to 1,000,000 IOPS with < 0.5ms latency
- Snapshots, compression and low-cost
- Point-in-time instantaneous cloning (helpful for testing new workloads)

## Storage Gateway
- Bridge between on-premises data and cloud data in S3 (S3 is an AWS proprietary technology, so it cannot be stored on-premises)
- Use cases: disaster recovery, backup and restore, tiered storage
- 3 types of Storage Gateway:
	- File Gateway
	- Volume Gateway
	- Tape Gateway

### File Gateway
- Configured S3 buckets are accessible using the NFS and SMB protocol
- Supports S3 standard, S3 IA, S3 One Zone IA
- Transition to S3 Glacier using a Lifecycle Policy
- Bucket access using IAM roles for each File Gateway
- Most recently used data is cached in the file gateway
- Can be mounted on many servers
- Integrated with Active Directory (AD) for user authentication
- Native access to FSx for Windows File Server

### Volume Gatewway
- Block storage using iSCSI protocol backed by S3
- Backed by EBS snapshots which can help restore on-premises volumes
- **Cached volumes**: low latency access to most recente data
- **Stored volumes**: entire dataset is on premise, scheduled backups to S3

### Tape Gateway
- Backup data to physical tapes, but in the cloud
- Virtual Tape Library (VTL) backed by S3 and Glacier
- Back up data using existing tape-based processes (and iSCSI interface)
- Works with leading backup software vendors

## AWS Transfer Family
- A fully amnaged service for file transfer into and out of S3 or EFS using the FTP protocol
- Supported protocols
	- AWS Transfer for FTP (only within VPC)
	- AWS Transfer for FTPS (File Transfer Protocol over SSL)
	- AWS Trasnfer for SFTP (Secure File Transfer Protocol)
- Managed infrastructure, scalable, reliable, highly available (multi AZ)
- Pay per provisioned endpoint per hour + data transfers in GB
- Store and manage users credentials within then service
- Integrate with existing auth systems (Microsoft Active Directory, LDAP, Amazon Cognito, custom)
- Use cases: sharing files, public datasets, CRM, ERP

## AWS Data Sync
- Move large amount of data to and from
	- On-premises / other cloud to AWS - needs agent
	- AWS to AWS (different storage services) - no agent needed
- Can synchronize to:
	- Amazon S3 (any storage classes, including Glacier)
	- Amazon EFS
	- Amazon FSx
- Replication tasks are not running continuously, they can be scheduled hourly, daily or weekly
- **File permissions and metadata are preserved**
- One agent task can use 10 Gbps, can setup a bandwidth limit

## All Storage Options Comparison
- S3: Object Storage
- Glacier: Object Archival
- EFS: Network File System for Linux instances, POSIX filesystem
- FSx for Windows: Netowrk File System for Windows servers
- FSx for Lustre: High Performance Computing Linux file system
- FSx for NetApp ONTAP: High OS Compatibility
- FSx for OpenZFS: Managed ZFS File system
- EBS volume: Network storage for one EC2 instance at a time
- Instance Storage: Physical storage for your EC2 instance (high IOPS)
- Storage Gateway: File Gateway, Volume Gateway (cached or stored), Tape Gateway
- Transfer Family: FTP, FTPS, SFTP interface on top of S3 or EFS
- DataSync: Schedule data sync from on-premises to AWS, or AWS to AWS
- Snowcone/Snowball/Snowmobile: to move large amount of data to the cloud, physically
- Database: for specific workloads, usually with indexing and querying