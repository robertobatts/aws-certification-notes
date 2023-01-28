# S3 Advanced and Athena

## S3 MFA-Delete
- MFA forces user to generate a code on a device before doing important operations on S3
- To use MFA-Delete, enable Versioning on the S3 bucket
- You will need MFA to permanently delete an object veersion and suspend versioning on the bucket
- You won't need MFA to enable versioning and listing deleted versions
- Only the bucket owner (root account) can enable/disable MFA-Delete
- MFA-Delete currently can only be enabled using the CLI

## S3 Access Logs
- You can log any request made to S3, from any account, authorized or denied
- The logs will go into another S3 bucket
- This data can also be analyzed using data analysis tools
- **Important to know**
	- DO NOT set your logging bucket to be the monitored bucket, otherwise it will create a logging loop, and your bucket will grow in size exponentially


## S3 Default Encryption
- One way to force encryption is to use a bucket policy and refuce any API call to PUT an S3 object without encryption headers
- Another way is to use the "default encruption" option in S3
- Note: Bucket Policies are evaluated before default encryption

## S3 Replication (CRR and SRR)
- Must enable versioning in source and destination buckets
- Cross Region Replication (CRR)
- Same Region Replication (SRR)
- Buckets can be in different accounts
- Copying is asyncronous
- Must give proper IAM permissions to S3

**CRR Use cases**: compliance, lower latency access, replication across accounts
**SRR Use cases**: log aggregation, live replication between production and test accounts

- After activating, only new objects are replicated
- To replicate existing objects, you need to use **S3 Batch Replication**
- For DELETE operations:
	- Can replicate delete markers from source to target (optional setting)
	- Deletions with a version ID are not replicated to avoid  malicious delete
- There is no "chaining" replication
	- If bucket 1 has replication into bucket 2, which has replication into bucket 3, then objects created in bucket 1 are not replicated to bucket 3

## S3 pre-signed URLs
- Can generate pre-signed URLs using SDK or CLI
- Valid for 3600 seconds by default, can change timeout with --expires-in-{TIME_BY_SECONDS} argument
- Users given a pre-signed URL inherit the permissions of the person who generated the URL for GET/PUT

## S3 Storage Classes
You can move between classes manually or using S3 Lifecycle configurations. The types of storage classes are the following:
- Standard - General Purpose
- Stanrdard-Infrequent Access (IA)
- One Zone-Infrequent Access
- Glacier Instant Retrieval
- Glacier Flexible Retrieval
- Glacier Deep Archive
- Intelligent Tiering

### S3 Durability and Availablity
- Durability
	- High durability (11 9s) of objects across multiple AZs
	- If you store 10,000,000 objects with S3, you can expect on avarage a loss of a single object every 10,000 years
	- Same for all storage classes
- High availability
	- Measures how readily available a service is
	- Varies depending on storage class

### S3 Standard - General Purpose
- 99.99% availability (4 9s)
- Used for frequently accessed data
- Low latency and high throughput
- Sustain 2 concurrent facility failures
- Use Cases: big data analytics, mobile and gaming applications, content distribution

### S3 Infrequent Access
- For data that is less frequently accessed but requires rapid access when needed
- Lower cost than S3 Standard
- **Standard-Infrequent Access**
	- 99.9% availability
	- Use case: disaster recovery, backups
- **One Zone-Infrequent Access**
	- 11 9s durability in a single AZ, data is lost when AZ is destroyed
	- 99.5% availability
	- Use case: storing secondary backup copies, data you can recreate

### Glacier
- Low cost object storage meant for archiving/backup
- You pay for storage and for retrieving objects
- **Glacier Instant Retrieval**
	- Millisecond retrieval, great for data accessed once a quarter
	- Minimum storage duration of 90 days
- **Glacier Flexible Retrieval**
	- The tpye of retrievals are Expedited (1 to 5 minutes), Standard (3 to 5 hours), Bulk (5 to 12 hours). Bulk is free
	- Minimum storage duration of 90 days
- **Glacier Deep Archive**
	- Standard (12 hours), Bulk (48 hours)
	- Minimum storage duration of 180 days

### S3 Intelligent Tiering
- Small monthly monitoring and auto-tiering free
- Moves object automatically between Access Tiers based on usage
- There are no retrieval charges in S3 Intelligent Tiering
- *Frequent Access tier (automatic)*: default tier
- *Infrequent Access tier (automatic)*: objects not accessed for 30 days
- *Archive Access tier (automatic)*: objects not accessed for 90 days
- *Archive Access tier (optional)*: configurable from 90 to 700+ days
- *Deep Archive Access tier (optional)*: configurable from 180 to 700+ day

### S3 Storage Classes Comparison
![[s3-classes-comparison.png]]

## Moving between storage classes
- You can transition objects between storage classes
- For infrequently accessed objects, move them to STANDARD_IA
- For archive objects you don't need in real-time, GLACIER or DEEP_ARCHIVE
- Moving objects can be automated using a lifecycle configuration
- You cannot move an object from GLACIER to STANDARD_IA, you have to restore the object and copy the restored object to IA

![[s3-moving-between-storage-classes.png]]

## S3 Lifecycle Rules
- **Transition actions**: it defines when objects are transitioned to another storage class
	- Move objects to Standard IA class 60 days after creation
	- Move to Clacier for archiving after 6 months
- **Expiration actions**: configure objects to expire (delete) after some time
	- Accesss log files can be set to delete after 365 days
	- Can be used to delete old versions of files (if versioning is enabled)
	- Can be used to delete incomplete multi-part uploads *
- Rules can be created for a certain prefix (e.g. s3://mybucket/mp3/* )

## S3 Analytics
- You can setup S3 Analytics to help determin when to transition objects from Standard to Standard_IA
- Does not work for OneZone_IA or Glacier
- Report is updated daily
- Takes about 24h to 48h to first start
- Good first step to put together Lifecycle Rules or improve them

## S3 Performance
### Baseline Performance
- S3 automatically scales to high request rates, with a latency of 100-200 ms
- Your application can achieve at least 3500 PUT/COPY/POST/DELETE and 5500 GET/HEAD requests per second per prefix in a bucket
- There are no limits to the number of prefixes in a bucket
- If an object path is bucket/folder/sub/file, then its prefix is folder/sub

### KMS Limitation
- If you use SSE-KMS you may be impacted by the KMS limits
- When you upload, it calls the GenerateDataKey KMS API
- When you download, it calls Decrypt KMS API
- The KMS quota is 5500, 10000 or 30000 req/s based on region
- You can request a quota increase using the Service Quotas Console

### Multi-Part Upload
- Recommended for files > 100 MB, must use for files > 5 GB
- Can help parallelize uploads 

### Transfer Acceleration
- Increase transfer speed by transferring file to an AWS edge location which will forward the data to the S3 bucket in the target region
- Compatible with multi-part upload
- The name of the bucket must be DNS compliant and not contain periods in order to use Transfer Acceleration

### Byte-Range Fetches
- Parallelize GETs by requesting specific byte ranges
- Better resilience in case of failures
- Can be used to speed up downloads
- Can be used to retrieve partial data

## S3 Select and Glacier Select
- Retrieve less data using SQL by performing server side filtering
- Can filter by rows and columns (simple SQL statements)
- Less network transfer, less CPU cost client-side

![[s3-glacier-select.png]]

## S3 Event Notifications
- Examples of S3 events are S3:ObjectedCreated, S3:ObjectRemoved, S3:ObjectRestore, S3:Replication ...
- Object name filtering is possible (e.g. * .jpg)
- Use case: generate thumbnails of images uploaded to S3
- You can create as many S3 events as desiderd
- S3 event notifications typically deliver events in second but can sometimes take a minute or longer
- The main destinations of the event are Lambda, SNS, SQS and EventBridge

## S3 Requester Pays
- In general, bucket owners pay for all S3 storage and data transfer costs associated with their bucket
- With **Requester Pays buckets**, the request pays the cost of the request and data download from the bucket
- Helpful if you want to share large datasets with other accounts
- The requester must be authenticated in AWS in order to bill them

## Athena
- Serverless query service to perform analytics against S3 objects
- Uses standard SQL language to query the files
- Supports CSVm JSON, ORC  Avro and Parquet
- Pricing: $5.00 per TB of data scanned
- Use compressed or columnar data for cost-savings (less scan)
- Use cases: business intelligence, analytics, reporiting, query VPC flow logs, ELB logs, CloutTrail trails, etc..

## Glacier Valut Lock
- Adopt a WORM model (Write Once Read Many)
- Lock the policy for future edits (can no longer be changed)
- Helpful for compliance and data retention

## S3 Object Lock
- Adopt a WORM model
- Must enable versioning
- Block an object version deletion for a specified amount of time
- Object retention:
	- Retention period: specifies a fixed period
	- Legal Hold: same protection, no expiry date
- Modes:
	- Governance mode: users can't overwrite or delete an object version or alter its lock settings unless they have special permissions
	- Compliance mode: a protected object version can't be overwritten or deleted by any user, including the root user of the account. When an object is locked in compliance mode, its retention mode can't be changed and its retention period can't be shortened


## S3 Batch Operations
- Perform bulk operations on existing S3 objects with a single request, example:
	- Modify object metadata and properties
	- Copy objects between S3 buckets
	- Encrypt un-encrypted objects
	- Modify ACLs, tags
	- Restore objects from S3 Glacier
	- Invoke Lambda to perform custom action on each object
- A job consists of a list of objects, the action to perform and optional paramters
- S3 Batch Operations manages, retries, track progress, sends completion notifications, generate reports...
- You can use **S3 Inventory** to get object list and use S3 Select to filter your objects