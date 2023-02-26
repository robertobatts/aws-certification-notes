# Databases in AWS

## Choosing the right database
Questions to choose the right database based on your architecture:
- Read-heavy, write-heavy or balanced workload? Throughput needs? Will it change, does it need to scale or fluctuate during the day?
- How much data to store and for how long? Will it grow? Average object size? How are they accessed?
- Data durability? Source of truth for the data?
- Latency requirements? Concurrent users?
- Data model? How will you query the data? Joins? Structured? Semi-Structured?
- Strong schema? More flexibility? Reporting? Search? RBDMS or NoSQL?
- Licence cost? Switch to Cloud Native DB such as Aurora?

### Database Types
- RDBMS (=SQL/OLTP): RDS, Aurora - great for joins
- NoSQL: DynamoDB (~JSON), ElastiCache (key/value pairs), Neptune (graphs) - no joins, no SQL
- Object Store: S3 (for big objects), Glacier (for backups/archives)
- Data Warehouse (=SQL Analytics/BI): redshift (OLAP), Athena
- Search: ElasticSearch (JSON) - free text, unstructured searches
- Graphs: Neptune - displays relationships between data


## RDS
- Managed PostgreSQL/MySQL/Oracle/SQL Server
- Must provision an EC2 instance and EBS Volume type and size
- Support for Read Replicas and Multi AZ
- Security through IAM, Security Groups, KMS, SSL in transit
- Backup/Snapshot/Point in time restore feature
- Managed and Scheduled maintenance
- Monitoring through CloudWatch
- Use case: Store relational datasets, perform SQL queries, transactional inserts/update/delete

### RDS for Solutions Architect
- **Operations**: small downtime when failover happens, when maintenance happens, scaling in read replicas/ec2/restore EBS implies manual intervention, application changes
- **Security**: AWS responsible for OS security, we are responsible for setting up KMS, security groups, IAM policies, authorizing users in DB, using SSL
- **Reliability**: Multi AZ feature, failover in case of failures
- **Performance**: depends on EC2 instance type, EBS volume type, ability to add read Replicas. Storage auto-scaling and manual scaling of instances
- **Cost**: pay per hour based on provisioned EC2 and EBS

## Aurora
- Compatible API with PostgreSQL/MySQL
- Data is held in 6 replicas, across 3 AZ
- Auto healing capability
- Multi AZ, Auto Scaling Read Replicas
- Read Replicas can be Global
- Aurora database can be Global for DR or latency purposes
- Auto scaling of storage from 10GB to 128TB
- Define Ec2 instance type for aurora instances
- Same security/monitoring/maintenance feature as RDS
- Aurora Serverless - for unpredictable/intermittent workloads
- Aurora Multi-Master - for continuous writes failover
- Use case: same as RDS, but with less maintenance, more flexibility and more performance

### Aurora for Solutions Architect
- **Operations**: less operations, auto scaling storage
- **Security**: AWS responsible for OS security, we are responsible for setting up KMS, security groups, IAM policies, authorizing users in DB, using SSl
- **Reliability**: Multi AZ, highly available, more than RDS, Aurora Serverless option, Aurora Multi-Master option
- **Performance**: 5x performance compared to RDS, up to 15 Read Replicas (only 5 for RDS)
- **Cost**: pay per hour based on EC2 and storage usage. Posibly lower cost compared to Enterprise grade databases such as Oracle

## ElastiCache
- Managed Redis/Memcached
- In-memory data store, sub-millisecond latency
- Must provision an EC2 instance type
- Support for clustering (Redis) and Multi AZ, Read Replicas (sharding)
- Security through IAM, Security Groups, KMS, Redis Auth
- Backup/Snapshot/Point in time restore feature
- Managed and Scheduled maintenance
- Monitoring through CloudWatch
- Use case: Key/Value store, frequent reads, less writes, cache results for DB queries, store session data for websites, cannot use SQL

### ElastiCache for Solutions Architect
- **Operations**: same as RDS
- **Security**: AWS responsible for OS security, we are responsible for setting up KMS, security groups, IAM policies, users (Redis Auth), using SSL
- **Reliability**: Clustering, Multi AZ
- **Performance**: sub-millisecond performance, in memory, read replicas for sharding, very popular cache option
- **Cost**: pay per hour based on EC2 and storage usage

## DynamoDB
- AWS proprietary technology, managed NoSQL database
- Serverless, provisioned capacity, auto scaling, on demand capacity
- Can replace ElastiCache as a key/value store (storing session data for example)
- Highly available, Multi AZ by default, Read and Writes are decoupled, DAX for read cache
- Reads can be eventually consistent or strongly consistent
- Security, authentication and authorization is done through IAM
- DynamoDB Streams to integrate with AWS Lambda
- Backup/Restore feature, Global Table feature
- Monitoring through CloudWatch
- Can only query on primary key, sort key, or indexes
- Use case: serverless applications development, distributed serverless cache, no SQL, transactions capability

### DynamoDB for Solutions Architect
- **Operations**: no operations needed, auto scaling capability, serverless
- **Security**: full security through IAM policies, LMS encryption, SSL in flight
- **Reliability**: Multi AZ, Backups
- **Performance**: single digit millisecond performance, DAX for caching reads, performance doesn't degrade if your application scales
- **Cost**: pay per provisioned capacity and storage usage (no need to guess in advance any capacity, can use auto scaling)

## S3
- S3 is a key/value store for objects
- Great for big objects, not so great for small objects
- Serverless, scales infinitely, max object size is 5TB
- Strong consistency
- Tiers: Standard, IA, One Zone IA, Glacier for backups
- Features: versioning, encryption, cross region replication, etc...
- Security: IAM, Bucket Policies, ACL
- Encryption: SSE-S3, SSE-KMS, SSE-C, client side encryption, SSL in transit
- Use case: static files, key value store for big files, website hosting

### S3 for Solutions Architect
- **Operations**: no operations needed
- **Security**: IAM, Bucket Policies, ACL, Encryption (server/client), SSL
- **Reliability**: 11 nines durability, 4 nines availability, Multi AZ, CRR
- **Performance**: scales to thousands of read/writes per second, transfer acceleration/multi-part for big files
- **Cost**: pay per storage usage, network cost, requests number

## DocumentDB
- DocumentDB is an "Aurora" version of MongoDB
- Used to store, query and index json data
- Similar deployment concepts as Aurora
- Fully managedm, highly available with replication across 3 AZ
- DocumentDB storage automatically grows in increaments of 10GB, up to 64TB
- Automatically scales to workloads with millions of requests per second

## Keyspaces (for Apache Cassandra)
- Apache Cassandra is an open-source NoSQL distributed database
- Keyspaces is a managed Apache Cassandra compatible database
- Serverless, scalable, highly available, fully managed by AWS
- Automatically scales tables up/down based on the application's traffic
- Tables are replicated 3 times across multiple AZs
- Use the Cassandra Query Language for querying
- Single-digit millisecond latency at any scale, 1000s of requests per second
- Capacity: on-demand mode or provisioned mode with auto-scaling
- Encryption, backup, PITR up to 35 days
- Use cases: store IoT devices info, time-series data, etc...

## QLDB (Quantum Ledger Database)
- A ledger is a book recording financial transactions
- Fully managed, serverless, highly available, replication across 3 AZs
- Used to review history of all the changes made to your application data over time
- Immutable system: no entry can be removed or modified, cryptographically verifiable
- 2-3x better performance than common ledger blockchain frameworks
- Manipulate date using SQL
- Difference with Amazon Managed Blockchain: QLDB is not decentralized, in line with many financial regulation rules

## Timestream
- Fully managed, fast, scalable, serverless time series database
- Automatically scales up/down to adjust capacity
- Store and analyze trillions of events per day
- 1000s times faster and 1/10th the cost of relational databases
- Scheduled queries, multi-measure records, SQL compatibility
- Data storage tiering: recente data kept in memory and historical data kept in a cost-optimized storage
- Built-in time series analytics functions (help you identify pattern in your data in neaer real-time)
- Encryption in transit and at rest
- User cases: IoT apps, operational applications, real-time analytics, etc...
- It can receive data from: AWS IoT, Lambda, Prometheus, Telegraf, Kineses Data Analytics

## Neptune
- Fully managed graph database
- Highly available across 3 AZ, with up to 15 read replicas
- Point in time recovery, continuous backup to S3
- Support for KMS encryption at rest + HTTPS
- Useful for high relationship data (social networking, knowledge graph)

### Neptune for Solutions Architect
- **Operations**: similar to RDS
- **Security**: IAM, VPC, KMS, SSL (similar to RDS) + IAM Authentication
- **Reliability**: Multi AZ, cluestering
- **Performance**: best suited for graphs, clustering to improve performance
- **Cost**: pay per node provisioned (similar to RDS)

