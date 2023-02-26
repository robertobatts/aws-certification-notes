## Athena
- Fully Serverless database with SQL capabilities
- Used to query data in S3
- Output results back to S3
- Pay per query
- Secured thorugh IAM
- Use case: one time SQL queries, serverless queries on S3, log analytics

### Athena for Solutions Architect
- **Operations**: no operations needed, serverless
- **Security**: IAM + S3 security
- **Reliability**: managed service, uses Presto engine, highly available
- **Cost**: pay per query/per TB of data scanned

## Redshift
- Based on PostgreSQL, but it's not used for OLTP
- It's OLAP - online analytical processing
- 10x better performance than other data warehouses
- Scale to PBs of data
- Columnar storage of data (instead of row based)
- Massively Paralle Query Execution (MPP)
- Pay as you go based on the instances provisioned
- Has a SQL interface for performing the queries
- BI tools such as AWS Quicksight or Tableau integrate with it
- Data is loaded from S3, DynamoDB, DMS, other DBs
- From 1 node to 128 nodes, up to 128TB of space per node
- Leader node: for query planning, results aggregation
- Compute node: for performing the queries, send results to leader
- Redshift Spectrum: perform queries directly against S3 (no need to load)
- Backup and Restore, Security VPC/IAM/KMS, Monitoring
- Redshift Enhanced VPC Routing: COPY/UNLOAD goes through VPC
- Use case: analytics, BI, data warehouse

### Snapshots and DR
- Redshift has no Multi AZ mode
- You have to create snapshots for DR
- Snapshots are point-in-time backups of a cluster, stored internally in S3
- Snapshots are incremental (only what has changed is saved)
- You can restore a snapshot into a new cluster
- Automated: eveery 8 hours, every 5GB or on a schedule. Set retention
- Manual: snapshot is retained until you delete it
- You can configure it to automatically copy snapshots of a cluster to another AWS Region

### Redshift Spectrum
- Query data that is already in S3 without loading it
- Must have a Redshift cluster availabled to start the query
- The query is then submitted to thousands of Redshift Spectrum nodes

### Redshift for Solutions Architect
- **Operations**: like RDS
- **Security**: IAM, VPC, KMS, SSL (like RDS)
- **Reliability**: auto healing features, cross-region snapshot copy
- **Performance**: 10x performance vs other data warehousing, compression
- **Cost**: pay per node provisioned, 1/10th of the cost vs other warehouses
- **vs Athena**: faster queries, joins and aggregations thanks to indexes

## OpenSearch
- Amazon OpenSearch is a successor of Amazon ElasticSearch
- You can search any field, even partially matches
- Common to use it as a complement to another database
- Has usage for Big Data applications
- You can provision a cluster of instances
- Built-in integrations: Kinesis Data Firehose, AWS IoT, CloudWatch Logs for data ingestion
- Security through Cognito and IAM, KMS encryption, SSL and VPC
- Compes with OpenSearch Dashboards (visualization)

### OpenSearch for Solutions Architect
- **Operations**: similar to RDS
- **Security**: Cognito, IAM, VPC, KMS, SSL
- **Reliability**: Multi AZ, clustering
- **Performance**: based on ElasticSearch project (open source), petabyte scale
- **Cost**: pay per node provisioned (similar to RDS)

## EMR
- EMR stands for Elastic MapReduce
- EMR helps creating Hadoop clusters (Big Data) to analyze and process vast amount of data
- EMR comes bundled with Spark, HBase, Presto, Flink and other tools used for big data
- EMR takes care of all the provisioning and configuration
- Auto-scaling and integrated with Spot instances
- Use cases: data processing, machine learning, web indexing, big data...

### Node types and purchasing
- Master Node: Manage the cluster, coordinate, manage health - long running
- Core Node: Run tasks and store data - long running
- Task Node (optional): just to run tasks - usually Spot
- Purchasing options:
	- On-demand: reliable, predictable, won't be terminated
	- Reserved (min 1 year): cost savings (EMR will automatically use if available)
	- Spot Instances: cheaper, can be terminated, less reliable
- Can have long running cluster, or transient (temporary) cluster

## QuickSight
- Serverless machine learning-powered business intelligence service to create interactive dashboards
- Fast, automatically scalable, embeddable in websites, with per-session pricing
- Use cases:
	- Business analytics
	- Building visualizations
	- Perform ad-hoc analysis
	- Get business insights using data
- Integrated with RDS, Aurora, Athena, Redshift, S3, Timestream, 3rd party services
- In-memory computation using **SPICE engine** if data is imported into QuickSight
- Enterprise edition: possibility to setup **Column-Level security (CLS)** to prevent some columns to be hidden to some users

### Dashboard and Analysis
- Define Users (standard version) and Groupos (enterprise version)
	- These users and groups only exist within QuickSight, not IAM
- A dashboard...
	- is a read-only snapshot of an analysis that you can share
	- preserves the configuration of the analysis (filtering, parameters, controls, sort)
- You can share the analysis or the dashboard with Users or Groups
- To share a dashboard, you must first publish it
- Users who see the dashboard can also see the underlying data

## Glue
- Managed extract, transform and load (ETL) service
- Useful to prepare and transform data analytics
- Fully serverless service
![[glue.png]]

### Glue Data Catalog
![[glue-data-catalog.png]]

#### Good to know at a high-level
- Glue Job Bookmarks: prevent re-processing old data
- Glue Elastic Views:
	- Combine and replicate data across multiple data stores using SQL
	- No custom code, Glue monitors for changes in the source data
	- Serverless
	- Leverages a virtual table (materialized view)
- Glue DataBrew: clean and normalize data using pre-built transformation
- Glue Studio: new GUI to create, run and monitor ETL jobs in Glue
- Glue Straming ETL (built on top of Apache Spark Structured Streaming): compatible with Kinesis Data Stream, Kafka, MSK

## Lake Formation
- Data lake = central place to have all your data for analytics purposes
- Fully managed service that makes it easy to setup a data lake in days
- Discover, cleanse, transform and ingest data into your data lake
- It automates many complex manual steps (collecting, cleansing, moving, cataloging data, ...) and de-duplicate (using ML Transforms)
- Fine-grained Access Control for your applications (row and column-level)
- Built on top of AWS Glue
- The data lake is stored in S3

## Kinesis Data Analytics
- Perform real-time analytics using SQL
- You can read only from Kinesis Data Streams and Kinesis Data Firehose
- Fully managed, no servers to provision
- Automatic scaling
- Real-time analytics
- Pay for actual consumption rate
- Can create streams out of the real-time queries
- Use cases: time-series analytics, real-time dashboards, real-time metrics 

![[kinesis-data-analytics.png]]

### Kinesis Data Analytics for Apache Flink
- Use Flink (Java, Scala or SQL) to process and analyze streaming data
- Run any Apache Flink application on a manageed cluster on AWS
- Automatic provisioning  of compute resources, parallel computation, automatic scaling
- Application backups
- Use any Apache Flink programming features
- Flink can only read from Kinesis Data Streams and MSK, not from Firehose

## MSK (Managed Streaming for Kafka)
- Alternative to Kinesis Data Streams
- Fully managed Apache Kafka on AWS
	- Allow you to create, update, delete clusters
	- MSK creates and manages Kafka brokeers nodes and Zookeper nodes for you
	- Deploy the MSK cluster in your VPC in multi-AZ (up to 3 for HA)
	- Automatic recovery from common Apache Kafka failures
	- Data is stored on EBS volumes for as long as you want
- MSK Serverless (optional)
	- Run Apache Kafka on MSK without managing the capacity
	- MSK automatically provisions resource and scales compute and storage