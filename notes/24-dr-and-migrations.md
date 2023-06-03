# Disaster Recovery and Migrations

## RPO and RTO
- RPO = Recovery Point Objective
- RTO = Recovery Time Objective
- The data created between the RPO and the disaster is loss
- The time between the disaster and the RTO is downtime

## Disaster Recovery Strategies
From the slower to the faster RTO:
- Backup and Restore
- Pilot Light
- Warm Standby
- Hot Site / Multi Site Approach

### Backup and Restore (High RPO)

![[backup-and-restore.png]]
Snapshots are faster to restore than Snowball, because sending Snowball back to Amazon takes a week.

### Pilot Light
- A small version of the app is always running in the cloud
- Useful for the critical core
- Very similar to Backup and Restore
- Faster than backup and Restore as critical systems are already up

![[pilot-light.png]]

### Warm Standby
- Full system is up and running, but at minimum size
- Upon disaster we can scale to production load

![[warm-standby.png]]

### Multi Site / Hot Site Approach
- Very low RTO (minutes or seconds), very expansive
- Full production scale is running on AWS and on premise

 ![[multi-site-approach.png]]

## Disaster Recovery Tips
- **Backup**
	- EBS snapshots, RDS automated backups/snapshots
	- Regular pushes to S3/S3 IA/Glacier, Lifecycle Policy, Cross Region Replication
	- From on-premise: Snowball or Storage Gateway
- **High Availability**
	- Use Route 53 to migrate DNS over from region to region
	- RDS Multi-AZ, ElastiCache Multi-AZ, EFS, S3
	- Site to Site VPN as a recovery from Direct Connect
- **Replication**
	- RDS Replication (cross region), AWS Aurora + Global Databases
	- Database replication from on-premise to RDS
	- Storage Gateway
- **Automation**
	- CloudFormation/Elastic Beanstalk to recreate a whole new environment
	- Recover/Reboot EC2 instances with CloudWatch if alarms fail
	- AWS Lambda functions for customized automations

## DMS - Database Migration Service
- Quickly and securely migrate databases to AWS, resilient, self healing
- The source database remains available during the migration
- Supports:
	- Homogeneous migrations: ex Oracle to Oracle
	- Heterogeneous migrations: ex Microsoft SQL Server to Aurora
- Continuos Data Replication using CDC (Change Data Capture)
- You must create an EC2 instance to perform the replication task

### DMS Sources and Targets
**Sources**:
- On-Premise and EC2 instances databases: Oracle, MS SQL Server, MySQL, MariaDB, PostgreSQL, MongoDB, SAP, DB2
- Azure: Azure SQL Database
- Amazon RDS
- Amazon Aurora
- Amazon S3

**Targets**:
- On-Premise and EC2 instances databases: Oracle, MS SQL Server, MySQL, MariaDB, PostgreSQL, SAP
- Amazon RDS
- Amazon Aurora
- Amazon Redshift
- Amazon DynamoDB
- Amazon S3
- OpenSearch Service
- Kinesis Data Streams
- DocumentDB

### AWS Schema Conversion Tool (SCT)
- Convert your Database's Schema from one engine to another
- You don't need to use SCT if you are migrating the same DB engine

### Continuous Replication

![[dms-continuous-replication.png]]

## RDS and Aurora MySQL/PostgreSQL Migrations
- RDS MySQL to Aurora MySQL (same for PostgreSQL)
	- Option 1: DB Snapshots from RDS restored as Aurora (can have downtime when switching database)
	- Option 2: Create an Aurora Read Replica from your RDS, and when the replication lag is 0, promote it as its own db cluster
- External MySQL to Aurora MySQL
	- Option 1:
		- Use Percona XtraBackup to create a file backup in S3
		- Create an Aurora db from S3
	- Option 2:
		- Create an Aurora db
		- Use the mysqldump utility to migrate MySQL into Aurora (slower than S3)
- External PostgreSQL to Aurora PostgreSQL
	- Create a backup and put it in S3
	- Import it using the aws_s3 Aurora extension
- Use DMS if both databases are up and running to do continuous replication

## On-Premise strategy with AWS
- You can download AMazon Linux 2 AMI as a VM (.iso format) and load it into VMWare, VirtualBox, KVM, Microsoft Hyper-V
- VM Import/Export
	- Migrate existing applications into EC2
	- Create a DR repoistory strategy for your on-premise VMs
	- Can export back the VMs from EC2 to on -premise
- AWS Application Discovery Service
	- Gather information about your on-premise servers to plan a migration
	- Server utilization and dependency mappings
	- Track with AWS Migration Hub
- AWS Database Migration Service (DMS)
	- replicate On-premis -> AWS, AWS -> AWS, AWS -> On-premise
	- Works with various databases
- AWS Server Migration Service (SMS)
	- Increamental replication of on-premise live servers to AWS

## AWS Backup
- Fully managed service
- Centrally manage and automate backups across AWS services
- No need to create custom scripts and manual processes
- Supported services: EC2, EBS, S3, RDS, Aurora, DynamoDB, DocumentDB, Neptune, EFS, FSx, Storage Gateway
- Supports cross-region backups
- Supports cross-account backups
- Supports PITR (point in time recovery) for supported services
- On-demand and Scheduled backups
- Tag-based backup policies
- You create backup policies known as Backup Plans, you can configure:
	- Backup frequency (every 12 hours, daily, weekly, monthly, cron expression)
	- Backup window
	- Transition to Cold Storage after configurable time
	- Retention Period

### AWS Backup Vault Lock
- Enforce a WORM (Write Once Read Many) state for all the backups that you store in your AWS Backup Vault
- Backups can't be deleted
- Defense to protect your backups against
	- Inadvertent or malicious delete operations
	- Updates that shorten or alter retention periods
- Even the root user cannot delete backups when enabled

## AWS Application Discovery Service
- Plan migration prohects by gathering information about on-premises data centers
- Server utilization data and dependency mapping are important for migrations
- There are two types of migrations you can do:
	- **Agentless Discovery (AWS Agentless Discovery Connector)**
		- VM inventory, configuration and performance history such as CPU, memory and disk usage
	- **Agent-based Discovery (AWS Application Discoverey Agent)**
		- System confriguration, system performance, running processes and details of the network connections between systems
- Resulting data can be viewed within AWS Migration Hub

## AWS Application Migration Service (MGN)
- Lift-and-shift (rehost) solution which simplify migrationg applications to AWS
- Converts your physical, virtual and cloud-based servers to run natively on AWS
- You have to install a AWS Replication Agent on your data centers, this will perform continuous replication of your disk to move everything to AWS
- DSupports wide range of platforms, operating systems and databases
- Minimal downtime, reduced costs

## Transferring large amount of data into AWS
- Example: transfer 200 TB of data in the cloud. We have a 100 Mbps internet connection
- Over the internet / Site-to-Site VPN:
	- Immediate to setup
	- Will take 200(TB)x1000(GB)x1000(MB)x8(Mb)/100Mbps = 16000000s = 185d
- Over direct connect 1 Gbps:
	- Long for the one-time setup (over a month)
	- Will take 18.5 days
- Over Snowball:
	- Will take 2 to 3 snowballs in parallel
	- Takes about 1 week for the end-to-end transfer
	- Can be combined with DMS
- For on-going replication/transfers: Site-to-Site VPN or DX (Direct Connect) with DMS or DataSync

## VMWare Cloud on AWS
- Some customers use VMware Cloud to manage their on-premises Data Center
- They want to extend the Data Cenbter capacity to AWS, but keep using the VMware Cloud software to manage everything
- You can extend your entire VMWare Cloud infrastructure to run on AWS
- Use cases
	- Migrate your VMware vSphere-based workloads to AWS
	- Run your production workloads across VMware vSphere-based private, public and hybrid cloud environments
	- Have a disater recovery strategy
