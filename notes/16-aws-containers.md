# Containers on AWS: ECS, Fargate, ECR and EKS

## Docker
- Docker is a software development platform to deploy apps
- Apps are packaged in containers that can be run on ay OS
- Apps run the same, regardless of where they're run
- Use cases: microservices, lift-and-shift apps from on-premises to the cloud

### Storing Images
Docker images can be stored in Docker repositories
- **Docker Hub**
	- Public repository
	- Find base images for many technologies or OS
- **Amazon ECR (Elastic Container Registry)**
	- Private repository
	- Public repository (Amazon ECR Public Gallery)

## Amazon ECS - Elastic Container Service
### EC2 Launch Type
- Launch Docker containers = Launch ECS Tasks on ECS Clusters
- You must provision and maintain the infrastructure (the EC2 instances)
- Each EC2 instance must run the EC2 Agent to register in the ECS Cluster
- AWS takes care of starting/stopping containers

### Fargate Launch Type
- Launch Docker containers on AWS
- You don't provision the infrastructure (no EC2 instance to manage)
- It's all serverless
- You just create task definitions
- AWS just runs ECS Tasks for you based on the CPU/RAM you need
- To scale, just increase the number of tasks

### IAM Roles for ECS
- **EC2 Instance Profile (EC2 Launch Type only)**
	- Used by the ECS agent
	- Makes API calls to ECS service
	- Send container logs to CloudWatch Logs
	- Pull Docker image from ECR
	- Reference sensitive data in Secrets Manager or SSM Parameter Store
- **ECS Task Role**
	- Allows each task to have a specific role
	- Use different roles for the different ECS Services you run
	- Task Role is defined in the task definition

### Load Balancer Integrations
- Application Load Balancer supported and works for most use cases
- Network Load Balancer recommended only for high throughput/high performance use cases, or to pair it with AWS Private Link

### Data Volumes (EFS)
- Mount EFS file systems onto ECS tasks
- Works for both EC2 and Fargate launch types
- Tasks running in any AZ will share the same data in the EFS
- Fargate + EFS = Serverless
- Use cases: persistent multi AZ shared storage for your containers
- Note: S3 cannot be mounted as a file system

### ECS Service Auto Scaling
- Automatically increase/decrease the desired number of ECS tasks
- ECS Auto Scaling uses AWS Application Auto Scaling, it can use three metrics:
	- ECS Service Average CPU Utilization
	- ECS Service Average memory Utilization
	- ALB Request Count per Target
- **Target Tracking** - scale based on target value for a specific CloudWatch metric
- **Step Scaling** - scale based on a specified CloudWatch Alarm
- **Scheduled Scaling** - scale based on a specified data/time
- ECS Service Auto Scaling (task level) is different then EC2 Auto Scaling (instance level)
- Fargate Auto Scaling is much easier to setup (because is serverkess)

#### Auto Scaling EC2 Instances
- **Auto Scaling Group**
	- Scale your ASG based on CPU Utilization
	- Add EC2 instances over time
- **ECS Cluster Capacity Provider**
	- Used to automatically provision and scale the infrastructure for your ECS Tasks
	- Capacity Provider paired with an Auto Scaling Group
	- Add EC2 instances when you'r missing capacity

## ECS Rolling Updates
- When updating from v1 to v2, we can control how many tasks can be started and stopped, and in which order
- It can bi configured through the paramters **Minimum healthy percent** and **Maximum percent**

![[ecs-rolling-update-example-1.png]]
![[ecs-rolling-update-example-2.png]]

## Amazon ECR - Elastic Container Registry
- Store and manage Docker images on AWS
- Private and Public repository
- Fully integrated with ECS, backed by S3
- Access is controlled through IAM (if there is a permission error, check the policy)
- Supports image vulnerability scanning, versioning, image taks, image lifecycle, etc...

## EKS Overview - Elastic Kubernetes Service
- It's a way to launch managed Kubernetes cluster on AWS
- Kubernetes is an open-source system for automatic deployment, sacling and management of containerized application
- It's an alternative to ECS
- EKS supports EC2 if you want to deploy worker nodes or Fargate to deploy serverless containers
- Use case: if your company is already using Kubernetes on-premises or in another cloud and want to migrate to AWS using Kubernetes
- Kubernetes is cloud-agnostic

![[eks-diagram.png]]

#### Node Types
- Managed Node Grouops
	- Creates and manages Nodes (EC2 instances) for you
	- Nodes are part of an ASG managed by EKS
	- Supports On-Demand or Spot Instances
- Self-Managed Nodes
	- Nodes created by you and registered to the EKS cluster and manged by an ASG
	- You can use prebuilt AM - Amazon EKS Optimized ami
	- Supports On-Demand or Spot Instances
- AWS Fargate
	- No maintenance required, no nodes managed

#### Data Volumes
- Need to specify StorageClass manifest on your EKS cluster
- Leverages a Container Storage Interface (CSI) compliant driver
- Supports for EBS, EFS, FSx
- EFS is the only volume that works with 

## App Runner
- Fully managed service that makes it easy to deploy web apps and APIs at scale
- No infrastructure experience required
- You only need to setup vCPU, RAM, Auto Scaling and health checks
- Start with your source code or container image
- Automatically builds and deploy the web app
- Automatic scaling, highly available, load balancer, encryption
- VPC access support to connect to database, cache and queues
- Use cases: web apps, APIs, microservices, rapid production deployments