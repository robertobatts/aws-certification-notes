# Decoupling Applications: SQS, SNS, Kinesis, Active MQ

## SQS  - Simple Queue Service
- Unlimited throughput, unlimited number of messages in queue
- Message retention: default 4 days, up to 14 days
- Low latency (< 10 ms on publish and receive)
- Limitation of 256KB per message sent
- Can have duplicate messages occasionally
- Can have out of order messages

### Producing Messages
- Produced to SQS using SDK (SendMessage API)
- The message is persisted in SQS until a consumer delets it

### Consuming Messages
- Consumers can run on EC2 instances, server, lambda, etc...
- Poll SQS for messages (receive up to 10 messages at a time)
- After processing, the consumer will delete the messages from the queue using the DeleteMessage API

### Multiple EC2 Instances Consumers
- We can have multiple consumes that receive and process messages in parallel from a queue
- At least once delivery: if a message is not processed fast enough, it will be receive by other consumers. In the settings, this time can be configured as Visibility Timeout
- Best-effort message ordering
- Consumers delete messages after processing them
- We can scale consumers horizontally to improve throughput for processing

### Security
- Encryption:
	- In-flight encryption using HTTPS API
	- At-rest encryption using KMS keys
	- Client-side encryption if the client wants to perform encryption/decryption itself
- Access Controls: IAM policies to regulate access to the SQS API
- SQS Access Policies (similar to S3 bucket policies)
	- Useful for cross-account access to SQS queues
	- Useful for allowing other services to write to an SQS queue

### Message Visibility Timeout
- After a message is polled by a consumer, it becomes invisible to other consumers
- By default, the message visibility timeout is 30 seconds
- This means that the message has 30 seconds to be processed, if not the message will be reinserted in the queue, and so it will be processed twice
- A consumer could call the ChangeMessageVisibility API to get more time
- If visibility timeout is high (hours) and consumer crashes, re-procesing will take time, because the message will appear again in the queue after hours
- If visibility timeout is too low (seconds), we may get duplicates

### Dead Letter Queue
- We can set a threshold of how many times a message can go back to the queue, to avoid failure loops caused by a message that cannot be processed by the consumer
- After the **MaximumReceives** threshold is exceeded, the message goes into a dead letter queue (DLQ)
- Useful for debugging
- You can set a retention time for DLQ, after that the messages will expire

### Redrive to Source
- Feature to help consume messages in the DLQ to understand what is wrong with them
- When our code is fixed, we can redrive the messages from the DLQ back into the source queue (or any other queue) in batches without writing custom code

### Delay Queue
- Delay a message (consumers don't see it immediately) up to 15 minutes
- Default is 0 seconds
- Can set a default at queue level
- Can override the default on send using the **DelaySeconds** parameter

### Long Polling
- When a consumer requests messages from the queue, it can optionally wait for messages to arrive if there are none in the queue
- Lond polling decreases the number of APPI calls made to SQS while increasing the efficiency and latency of your application
- Long polling is preferrable to short polling
- The wait time can be configured between 1 and 20 seconds
- Long polling can be enabled at the queue level or at the API level using **WaitTimeSeconds**

### Request-Response Systems
This pattern can be implemented with SQS Temporary Queue Client
![[sqs-request-response-pattern.png]]

### FIFO Queues
- FIFO = First In First Out (guarantee of order in the messages)
- Limited throughput: 300 msg/s without batching, 3000 msg/s with batching
- Exactly-once send capability (by removing duplicates)
- Messages are processed in order by the consumer
- The name of the queue must end with ".fifo"
- You can have one consumer per Group ID

## SQS + Auto Scaling Group
![[sqs-auto-scaling.png]]


## SNS - Simple Notification Service
- The event producer only sends message to one SNS topic
- Youu can set as many event receivers (subscriber) as you want to listen to the SNS topic notifications
- Each subscriber to the topic will get all the messages
- Up to 12,500,000 subscriptions per topic
- Up to 100,000 topics
- SNS can pubblish messages to Emails, SMS, Mobile notifications, HTTP(S) endpoints, SQS, Lambda, Kinesis Data Firehose
- Can receive messages from a lot of AWS services

### How to publish
- Topic Publish (using the SDK)
	- Create a topic
	- Create a subscription (or many)
	- Publish to the topic
- Direct Publish (for mobile apps SDK)
	- Create a platform application
	- Create a platform endpoint
	- Pubblish to the platform endpoint

### Security
Same security settings of SQS

### Message Filtering
- JSON oplicy used to filter messages sent to SNS topic's subscriptions
- If a subscription doesn't have a filter policy, it receives every message

## SNS and SQS - Fan Out Pattern
- Push once in SNS, receive in all SQS queues that are subscribers
- Fully decoupled model, no data loss
- SQS allos for data persistence, delayed processing and retries of work
- Ability to add more SQS subscribers over time
- Make sure your SQS queue access policy allows for SNS to write

### S3 Events to multiple queues
- For the same combination of: event type (e.g. object create) and prefix (e.g. images/) you can only have one S3 Event rule
- If you want to send the same S3 event to many SQS queues, you should use fan-out

### SNS FIFO + SQS FIFO
- SNS FIFO can only have SQS FIFO queues as subscribers
- usefule if you need fan out + ordering + deduplication

## Kinesis
- Makes it easy to collect, process and analyze streaming data in real-time
- Ingest real-time data such as: Application logs, Metrics, Website clickstreams, IoT telemetry data
- **Kinesis Data Streams**: capture, process and store data streams
- **Kinesis Data Firehose**: load data streams into AWS data stores
- **Kinesis Data Analytics**: analyze data streams with SQL or Apache Flink
- **Kinesis Video Streams**: capture, process and store video streams

### Kinesis Data Streams
- Retention between 1 day to 365 days
- Ability to reprocess (replay) data
- Once data is inserted in Kinesis, it can't be deleted (immutability)
- Data that shares the same partition key  goes to the same shard (ordering)
- Can have only one consumer per shard
- Producers: AWS SDK, Kinesis producer Library (KPL), Kinesis Agent
- Consumers: Kinesis Client Library (KCL), AWS SDK, Lambda, Kinesis Data Firehose, Kinesis Data Analytics
- **Provisioned mode**:
	- You choose the number of shards provisioned, scale manually or using API
	- Each shard gets 1 MB/s in (or 1000 records per second)
	- Each shard gets 2 MB/s out (classic or enhanced fan-out consumer)
	- You pay per shard provisioned per hour
- **On-demand mode**:
	- No need to provision or manage the capacity
	- Default capacity provisioned (4 MB/s in or 4000 records per second)
	- Scales automatically based on observed throughput peak during the last 30 days
	- Pay per stream per hour and data in/out per GB

![[kinesis-data-streams.png]]

### Kinesis Data Firehose
- Fully managed service, no administration, automatic scaling, serverless
- Pay for data going through Firehose
- Near Real Time
	- 60 seconds latency minimum for non full batches
	- Or minimum 32 MB of data at a time
- Supports many ddata formats, conversion, transformations, compression
- Supports custom data transformations using AWS Lambda
- Can send failed or all data to a backup S3 bucket

![[kinesis-data-firehose.png]]

### Kinesis Data Analytics
- Perform real-time analytics on Kinesis Streams using SQL
- Fully managed, no servers to provision
- Automatic scaling
- Real-time analytics
- Pay for actual consumption rate
- Can create streams out of the real-time queries
- Use cases: time-series analytics, real-time dashboards, real-time metrics 

![[kinesis-data-analytics.png]]

## SQS vs SNS vs Kinesis

![[sqs-sns-kinesis-comparison.png]]

## Amazon MQ
- SQS and SNS are cloud-native services, they're using proprietary protocols from AWS
- When migrating to the cloud, instead of re-engineering the application to use SQS and SNS, we can use Amazon MQ
- Amazon MQ = managed Apache ActiveMQ
- Amazon MQ doesn't scale as much as SQS and SNS
- It runs on adedicated machine, can run in HA with failover
- It has both queue feature and topic feature
- You can use EFS as storage, so that in case of failover, the new Amazon MQ instance will connect to the same storage and have the same data
