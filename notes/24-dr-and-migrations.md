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
- Continuow Data Replication using CDC (Change Data Capture)
- You must create an EC2 instance to perform the replication task

### DMS Sources and Targets
**Sources**:
- On-Premise and EC2 instances databases: Oracle, MS SQL Server, MySQL, MariaDB, PostgreSQL, MongoDB, SAP, DB2
- Azure: Azure SQL Database
- Amazon RDS: all including Aurora
- Amazon S3

**Targets**:
- On-Premise and EC2 instances databases: Oracle, MS SQL Server, MySQL, MariaDB, PostgreSQL, SAP
- Amazon RDS
- Amazon Redshift
- Amazon DynamoDB
- Amazon S3
- ElasticSearch Service
- Kinesis Data Streams
- DocumentDB

### AWS Schema Conversion Tool (SCT)
- Convert your Database's Schema from one engine to another
- You don't need to use SCT if you are migrating the same DB engine

### Continuous Replication

![[dms-continuous-replication.png]]

