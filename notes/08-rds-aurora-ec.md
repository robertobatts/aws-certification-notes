# RDS, Aurora and ElastiCache

## RDS - Relational Database Service
- It's a managed DB service and it uses SQL as a query language
- It allows you to create databases in the cloud that are managed by AWS: PostgreSQL, MySQL, MariaDB, Oracle, Microsoft SQL Server, Aurora

### Using RDS vs deploying our DB on EC2
Using RDS it's more convenient because:
- Automated provisioning, OS patching
- Continuous backups and restore to specific timestamp
- Monitoring dashboards
- Read replicas for improved read performance
- Multi AZ setup for Disaster Recovery (DR)
- Scaling capability (vertical and horizontal)
- Storage backed by EBS (gp2 or io1)
- You can enable Delete Protection to avoid accidental deletion of the db

The only disadvantage is that you can't SSH into your instances

### Backups
- Backups are automatically enabled in RDS
- Automated backups:
	- Daily full backup of the database
	- Transaction logs are backed-up by RDS every 5 minutes, this allows you to restore to any point in time up to 5 minutes ago
	- 7 days retention (can be increased to 35 days)
- DB Snapshots:
	- Manually triggered by the user
	- Retention of backup as long as you want\

### Storage Auto Scaling
- Helps you increase storage dynamically
- When RDS detectes you are running out of free db storage, it scales automatically
- You have to set **Maximum Storage Threshold** (max limit for db storage)
- The storage is automatically modified if:
	- Free storage is less than 10% of allocated storage
	- Low storage lasts at least 5 minutes
	- 6 hours have passed since last modification

### Read Replicas for read scalability
- Up to 5 Read Replicas
- They can be Within AZ, Cross AZ or Cross Region
- Async replication, so reads are eventually consistent
- Replicas can be promoted to their own DB and opt out from the replication mechanism
- Applications must update the connection string to leverage read replicas
- Use case:
	- You want to run a reporting app to run some analytics, so you create a replica and read from it to avoid slowing down the production db used by the users

#### Network Cost
- For RDS Read Replicas within the same region, you don't pay a network fee
- If the replicas are in different regions, you pay the network fee

### Multi AZ (Disaster Recovery)
- Sync replication
-  One DNS name, so there is automatic app failover to standby
- Increase availability
- Failover in case of loss of AZ, loss of network, instance or storage failure
- The Read Replicas can be set as Multi AZ for Disaster Recovery

### Turn a Single-AZ RDS into Multi-AZ
- Zero downtime operation (no need to stop the DB)
- Just click on "modify" for the database
- Behind the scenese, the following happens:
	- A snapshot is taken
	- A new DB is restored from the snapshot in a new AZ
	- Synchronization is established between the two databases

### RDS Encryption
- Rest Encryption
	- Possibility to encrypt the master and read replicas with AWS KMS- AES-256 encryption
	- Encryption has to be defined at launch time
	- If the master is not encrypted, the read replicas cannot be encrypted
	- Transparent Data Encryption (TDE) available for Oracle and SQL Server
- In-flight Encryption
	- SSL certificates to encrypt data to RDS in flight
	- Provide SSL options with trust certificate when connecting to database
	- To enforce SSL:
		- **PostgreSQL**: rds.force_ssl=1 in the AWS RDS Console (Parameter Groups)
		- **MySQL** : whithin the DB run the following command 
		  `GRANT USAGE ON *.* TO 'MYSQLUSER'@'%' REQUIRE SSL;`

#### Encryption Operations
- **Encrypting RDS backups**
	- Snapshots of unencrypted RDS databases are unencrypted
	- Snapshots of encrypted RDS databases are encrypted
- **To encrypt an unencrypted RDS db**
	- Create a snapshot of the unencrypted db
	- Copy the snapshot and enable encryption on the new snapshot
	- Restore the db from the encrypted snapshot
	- Migrate applications to the new db and delete the old db

### RDS Security - Network and IAM
- Network Security
	- RDS databases are usually deployed within a private subnet, not in a public one
	- RDS security works by leveraging security groups (same concept as for EC2 instances), it controls which IP/security group can communicate with RDS
- Access Management
	- IAM policies help control who can manage AWS RDS
	- Traditional Username and Password can be used to log into the db
	- IAM-based authentication can be used to login into MySQL and PostgreSQL

#### IAM Authentication
- It works for MySQL and PostgreSQL
- You don't need a password, just an auth token obtained through IAM and RDS API calls
- Auth token has a lifetime of 15 minutes
- Network in/out must be encrypted using SSL

![[iam-auth-token.png]]

## Amazon Aurora
- Aurora is a properietary (not open sourced)
- Postgres and MySQL are both supported as AuroraDB, this means your drivers will work as if Aurora was a Postgres or MySQL database
- Aurora is "AWS cloud optimized" and claims 5x performance improvement over MySQL on RDS, over 3x performance of Postgres on RDS
- Aurora storage automatically grows in increments of 10GB, up to 128 TB
- Aurora can have 15 replicas while MySQL has 6, and the replication process is faster (< 10 ms replica lag)
- Failover in Aurora is instantaneous
- Aurora costs 20% more than RDS, but is more efficient

### Aurora High Availability and Read Scaling
- 6 copies of your data across 3 AZ:
	- 4 copies out of 6 needed for writes
	- 3 copies out of 6 needed for reads
	- Self healing with peer-to-peer replication in case some data is corrupted
	- Storage is striped across 100s of volumes
- Writes are done only on master
- Automated failover for master in less than 30 seconds
- Up to 15 Read Replicas
- Support for Cross Region Replication

### Aurora DB Cluster
All the replicas are connected to a single endpoint, under which there is load balancing.
It is also possible to allow Multi-Master feature, to have multiple writer instances.

![[aurora-cluster.png]]

### Security
- Similar to RDS
- Encryption at rest using KMS
- Automated backups, snapshots and replicas are also encrypted
- Encryption in flight using SSL
- Possibility to authenticate with IAM token (same as RDS)
- You are responsible for protecting the instance with security groups
- You can't SSH

### Replicas Auto Scaling
Based on the replicas CPU Usage, the number of replicas can be scaled automatically, and be automatically connected to the Reader Endpoint

### Custom Endpoints
You can define a subset of Aurora instances as a Custom Endpoint. A reason to do that might be if you have a subset of instances that are more powerful, and so you want to use them specifically in a different application

### Serverless
- Automated database instantiation and auto scaling based on actual usage
- Good for infrequent, intermittent or unpredictable workloads
- No capacity planning needed
- Pay per second, can be more cost-effective

### Multi-Master
- In case you want immediate failover for write node
- Every node does R/W instead of promoting a Read replica as the new master

### Global Aurora
- 1 Primary Region (read/write)
- Up to 5 secondary regions (read-only), replication lag is less than 1 second
- Up to 16 Read Replicas per secondary region
- Helps for decreasing latency
- Promoting another region has an RTO of < 1 minute

### Aurora Machine Learning
- Enables you to add ML-based predictions to your applications via SQL
- Simple, optimized and secure integration between Aurora and AWS ML services
- Supported services:
	- Amazon SageMaker (use with any ML model)
	- Amazon Comprehend (for sentiment analysis)
- You don't need to have ML experience
- Use case: fraud detection, ads targeting, sentiment analysis, product recommendations

## ElastiCache
- Managed version of Redis or Memcached
- it has to be used by the application by doing code changes (i.e. query the cache before the db or whenever you need it)

### Redis vs Memcached
#### Redis
- Multi AZ with automatic failover
- Read Replicas to scale reads and have high availability
- data durability using AOF persistence
- Backup and restore features

#### Memcached
- Multi-node for partitioning of data (sharding)
- No replication
- No backup and restore
- Multithreaded architecture

### Cache Security
- Do not support IAM authentication
- IAM policies on ElastiCache are only used for AWS API-level security
- **Redis**
	- You can set a password/token when you create a Redis cluster
	- Supports SSL in flight encryption
- **Memcached**
	- Supports SASL-based authentication

### Patterns for ElastiCache
- **Lazy Loading**: all the read data is cached, data can become stale in cache
- **Write Through**: adds or update data in the cache when written to a DB (no stale data)
- **Session Store**: store temporary session data in a cache (using TTL)

## RDS Standard Ports
- 5432 - PostgreSQL or Aurora compatible with PostgreSQL
- 3306 - MySQL or Aurora compatible with MySQL
- 1521 - Oracle RDS
- 1433 - MSSQL Server
- 3306 - MariaDB