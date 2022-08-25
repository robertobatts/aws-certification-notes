# Serverless Solution Architecture Examples

## Mobile application: MyTodoList
- Expose as REST API with HTTPS
- Serveless architecture
- Users should be able to directly interact with their own folder in S3
- Users should authenticate through a managed serverless service
- Users can write and read to-dos, but they mostly read them
- The database should scale and have high read throughput

![[mobile-todo-list-architecture.png]]


## Serverless hosted website: MyBlog.com
- This website should scale globally
- Blogs are rarely written, but often read
- Some of the website is purely static files, the rest is a dynamic REST API
- Caching must be implemented where possible
- Any new users that subscribes should receive a welcome email
- Any photo uploaded to the blog should have a thumbnail generated

![[blog-serverless-architecture.png]]


## Microservices Architecture
- We want to switch to a microservice architecture
- Many services interact with each other directly using a REST API
- Each architecture for each micro service may vary in form and shape
- We want a microservice architecture so we can have a leaner development lifecycle for each service

![[microservice-architecture.png]]

## Distributing Paid Content
- We sell videos online and users have to pay to buy videos
- Each videos can be bought by many different customers
- We only want to distribute videos to users who are premium users
- We have hava a db of premium users
- Links we send to premium users should be short lived
- Our application is global
- We want to be fully serverless

![[distribute-paid-content-architecture.png]]


## Big Data Ingestion Pipeline
- We want the ingestion pipeline to be fully serverless
- We want to collect data in real time 
- We want to transform the data
- We want to query the transformed data using SQL
- The reports created using the queries should be in S3
- We want to load that data into a warehouse and create dashboards

![[big-data-pipeline-architecture.png]]
