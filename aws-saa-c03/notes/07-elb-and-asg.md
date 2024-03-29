# ELB and ASG

## Scalability and High Availability
##### Vertical Scalability
- It scales by increasing the size of the instance
- For example, your application runs on a t2.micro. Scaling it vertically means running it on a t2.large
- Very common for non distributed systems, such as a database
- There's usually a limit to how much you can scale (hardware limit)

##### Horizontal Scalability
- It scales by increasing the number of instances for your application
- It implies having a distributed system
- Very common for modern web applications

##### High Availability
- It's linked to scalability, but it's not the same
- It means running your application in at least 2 data centers (2 AZs)
- The goal is to survive a data center loss

## ELB - Elastic Load Balancing
- Load Balancers are servers that forward traffic to multiple servers
- Useful to spread load across multiple downstream instances
- Expose a single point of access (DNS) to your application
- Handle failures of instances (it doesn't forward traffic to unhealthy instances)
- Provide SSL termination (HTTPS) for your websites
- Enforce stickiness with cookies
- High availability across zones
- Separate public traffic from private traffic

### Types of load balancers in AWS
- **Application Load Balancer** (v2 - new generation): HTTP, HTTPS, Web Socket
- **Network Load Balancer** (v2 - new generation): TCP, TLS, UDP
- **Gateway Load Balancer**: Operates at layer 3 (network layer)

#### ALB - Application Load Balancer
- Support for HTTP/2 and WebSockets
- Supports redirects (e.g. from HTTP to HTTPS)
- Load balancing to multiple HTTP applications across machines (target groups)
- Load balancing to multiple applications on the same machine (e.g. containers)
- Routing tables to different target groups
	- Routing based on path in URL (example.com/users, example.com/posts)
	- Routing based on hostname in URL (one.example.com, other.example.com)
	- Routing based on Query String, Headers (example.com/users?id=123&order=false)
- Great fit for microservices and container-based application (e.g. Docker and Amazon ECS)
- Port mapping feature to redirect to a dynamic port in ECS

![[alb-traffic-1.png]]

##### ALB Target Groups
Target groups can be:
- EC2 instances
- ECS tasks
- Lambda functions
- Private IP addresses

ALB can route to multiple target groups, and the health checks are done at the target group level.
In the following example, we route the traffic into two different target groups based on a query parameter
![[alb-traffic-2.png]]

##### Good to Know
- Fixed hostname
- The application servers don't see the IP of the client directly
	- The true IP of the client is inserted in the header **X-Forwarded-For**
	- We can also get Port (X-Forwarded-Port) and proto (X-Forwarded-Proto)

#### NLB - Network Load Balancer
- Forward TCP and UDP traffic to your instances
- Handle million of requests per second
- Less latency ~ 100 ms (vs 400 ms for ALB)
- NLB has one static IP per AZ, and supports assigning Elastic IP (helpful for whitelisting specific IP)
- It forward the traffic from the client directly to the instance, therefore the access to the NLB is based on the security groups of the instances of the target group

##### NLB Target Groups
- EC2 instances
- Private IP addresses
- Application Load Balancer

#### GLB - Gateway Load Balancer
- Deploy, scale and manage a fleet of 3rd party network virtual appliances in AWS
- Example: Firewalls, Intrusion Detection Systems, Deep Packet Inspection Systems, payload manipulation
- Uses the GENEVE protocol on port 6081
- Combines the following functions:
	- **Transparent Network Gateway** - single entry/exit for all traffic
	- **Load Balancer** - distributes traffic to your virtual appliances

![[glb-traffic.png]]

##### GLB Target Groups
- EC2 instances
- Private IP addresses


## ELB Sticky Sessions
- It's possible to implement stickiness so that the same client is always redirected to the same instance behind a load balancer
- This works for CLB and ALB
- The cookie used for stickiness has an expiration date you can control
- Use case: make sure the user doesn't lose his session data
- Enabling stickiness may bring inbalance to the load over the backend EC2 instances

### Cookie Types
##### Application-based Cookies
- Custom cookie
	- Generated by the target
	- Can include any custom attributes required by the application
	- Cookie name must be specified individually for each target group
- Application Cookie
	- Generated by the load balancer
	- Cookie name is AWSALBAPP
##### Duration-based Cookies
- Generated by the load balancer
- Cookie name is AWSALB for ALB, AWSELB for CLB

## Cross-Zone Load Balancing
![[cross-zone-balancing.png]]

- **Application Load Balancer**:
	- Always on (can't be disabled)
	- No charges for inter AZ data
- **Network Load Balancer**:
	- Disabled by default
	- You pay charges for inter AZ data if enabled
- **Classic Load Balancer**:
	- Disabled by default
	- No charges for inter AZ data if enabled

## SSL Certificates
### Basics
- A SSL certificate allows traffic between your clients and your load balancer to be encrypted in transit
- SSL refers to Secure Sockets Layer, used to encrypt connections
- TLS refers to Transport Layer Security, which is a newer version
- Nowadays, TLS certificates are mainly used, but people stil refer as SSL
- Public SSL certificates are issued by Certificate Authorities (CA)
- SSL certificates have an expiration date and must be renewed

### Load Balancer
![[elb-ssl.png]]
- The load balancer uses an X.509 certificate
- You can manage certificates using ACM (AWS Certificate Manager)
- You can upload your own certificates as an alternative
- If you set a HTTPS listener:
	- You must specify a default certificate
	- You can add an optional list of certs to support multiple domains
	- Clients can use SNI (Server Name Indication) to specify the hostname they reach
	- Ability to specify a security policy to support older versions of SSL/TLS (legacy clients)

### Server Name Indication
- SNI solves the problem of loading multiple SSL certificates onto one web server to serve multiple websites
- It's a newer protocol and requires the client to indicate the hostname of the target server in the initial SSL handshake
- The server will then find the correct certificate, or return the default one
- Only works for ALB, NLB and CloudFront

## Deregistration Delay
This feature is named as Deregistration Delay for ALB and NLB, and as Connection Draining for CLB
- It gives time to instances to complete the active requests while the instance is de-registering or unhealthy
- It will stop sending  new requests to the EC2 instance while it's deregistering
- You can configure it from 1 to 3600 seconds (default is 300 seconds)
- Can be disabled by setting the value to 0
- It's convenient to set it to a low value if your requests are short, so that the instances can be deregistered quickly

## ASG - Auto Scaling Groups
- ASG is free, you only pay for the EC2 instances that gets created
- You can specify Minimum Capcity, Desired Capacity and Maximum Capacity
- It can be assigned to an ELB
- If assigned to an ELB, it can use the ELB configured health checks

### ASG Attributes
- Launch Template:
	- AMI + Instance Type
	- EC2 User Data
	- EBS Volumes
	- Security Groups
	- SSH Key Pair
	- IAM Roles
	- Network + Subnets information
	- Load Balancer information
- Min Size / Max Size / Initial Capacity
- Scaling Policy

### CloudWatch Alarms and Scaling
- It's possible to scale (in and out) an ASG based on CloudWatch Alarms
- An alarm monitors a metric (such as Average CPU or a custom metric)
- Metrics such as Average CPU are computed for the overall ASG instances

### Scaling Policies
- **Dynamic Scaling**:
	- **Target Tracking Scaling**:
		- Most simple and easy to set up
		- Example: I want the average ASG CPU to stay at around 50%
	- **Simple/Step Scaling**:
		- Example: when a CloudWatch alarm is triggered add or remove units
- **Scheduled Actions**:
	- Anticipate scaling based on known usage patterns
	- Example: increase the min capacity to 10 at 5pm on Fridays
- **Predictive Scaling**:
	- Continuously forecast load and schedule scaling ahead
	- Machine learning powered

### Good metrics to scale on
- CPUUtilization: Average CPU utilization across your instances
- RequestCountPerTarget: to make sure the number of requests per EC2 instances is stable
- Average Network In/Out
- Any custom metric that you push using CloudWatch

### Scaling Cooldowns
- After a scaling activity happens, you are in the **cooldown period** (300 seconds by default)
- During the cooldown period, the ASG will not launch or terminate additional instances to allow for metrics to stabilize
- Advice: Use a ready-to-use AMI to reduce configuration time in order to be serving requests faster and reduce the cooldown period

### ASG for Solutions Architects
#### Default Termination Policy
1. Find the AZ which has the most number of instances
2. If there a re multiple instances in the AZ to choose from, delete the one with the oldest launch configuration

#### Lifecycle Hooks
- By default, as soon as an instance is launched in an ASG it's in service
- You have the ability to perform extra steps before the instance goes in service (Pending state)
- You have the ability to perform some actions before the instance is terminated (Terminating state)
![[asg-lifecycle-hooks.png]]

#### Launch Template vs Launch Configuration
- **Both**:
	- You can specify AMI, instance tpye, key pair, security groups, tags,EC2 User Data, etc...
- **Launch Configuration** (legacy):
	- Must be recreated every time
- **Launch Template** (newer):
	- Can have multiple versions
	- Create parameter subsets (partial configuration for re-use and inheritance)
	- Provision using both On-Demand and Spot instances (or a mix)
	- Can use T2 unlimited burst feature