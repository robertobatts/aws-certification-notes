# Route 53
## DNS
### DNS Terminology
![[dns-terminology.png]]
### How DNS Works
![[dns-workflow.png]]

## Amazon Route 53
- A highly available, scalable, fully managed and Authoritative DNS
	- Authoritative = the customer can update the DNS records
- It's also a Domain Registrar (like GoDaddy, NameCheap, etc...)
- Ability to check the health of your resources
- The only AWS service which provides 100% availability
- 53 is a reference to the traditional DNS port

### Records
Records define how you want to route traffic for a domain. Each record contains:
- Domain/subdomain name - e.g. example.com
- Record Type - e.g. A, AAAA, CNAME, NS, etc...
- Value - e.g. 12.34.56.78
- Routing Policy - how Route 53 responds to queries
- TTL - amount of time the record cached at DNS Resolvers

### Record Types
- **A** - maps a hostname to IPv4
- **AAAA** - maps a hostname to IPv6
- **CNAME** - maps a hostname to another hostname
	- The target is a domain name which must have an A or AAAA record
	- Can't create a CNAME record for the top node of a DNS namespace (Zone Apex)
	- Example: you can't create it for example.com, but you can for www.example.com
- **NS** - Name Servers for the Hosted Zone
	- Control how traffic is routed to the domain

### Hosted Zones
It's a container for records that define how to route traffic to a domain and subdomains
- **Public Hosted Zones** - contains records that specify how to route traffic on the internet (public domain names)
- **Private Hosted Zones** - contain records that specify how you route traffic within one or more VPCs (private domain names)
You pay $0.50 per month per hosted zone

### Records TTL (Time To Live)
It's useful to cache the resonse from the DNS server, because DNS mappings should not change too often. In Route53, defualt TTL is 300 seconds.
TTL is mandatory for each DNS record, except for Alias.

### CNAME vs Alias
- **CNAME**
	- Points a hostname to any other hostname
	- Only for non root domains (e.g. something.mydomain.com)
- **Alias**
	- Points a hostname to an AWS Resource
	- Works for root domains and non root domains
	- Free of charge
	- Native health check
	- Automatically recognizes changes in the resource's IP address
	- Alias is always of type A/AAAA
	- You can't set TTL, it's set automatically by Route53

### Alias Record Targets
Possible targets can be:
- Elastic Load Balancers
- CloudFront Distributions
- API Gateway
- Elastic Beanstalk environments
- S3 websites
- VPC Interface Endpoints
- Global Accelarator
- Route53 record in the same hosted zone

You cannot set an Alias record for an EC2 DNS name

### Routing Policies
- Defines how Route53 responds to DNS queries
- Don't get confused by the word "Routing". It's not the same as Load Balancer routing which routes the traffic. DNS doesn't route any traffic, it only responds to DNS queries

These are types of routing policies you can have:

#### Simple Routing Policy
- Typically route traffic to a single resource
- Can specify multiple values in same record
- If multiple values are returned, a random one is chosen by the client
- When Alias is enabled, specify only one AWS resource
- Can't be associated with health checks

#### Weighted Routing Policy
- Control the percentage of the requests that go to each specific resource
- Assign each record a relative weight 
- DNS records must have the same name and type
- Can be associated with health checks
- Use cases: load balancing between regions, testing new application versions
- If all records have weight = 0, they will all be returned with the same weight

#### Latency Routing Policy
- Redirect to the resource that has the least latency close to us
- Super helpful when latency for users is a priority
- Latency is based on traffic between users and AWS Regions
- Can be associated with health checks

#### Failover Routing Policy
- You can specify a primary and a secondary record
- When the primary record is unhealthy, the traffic is directed to the secondary record

#### Gelocation Routing Policy
- The routing is based on user location
- Specify location by Continent, Country or US State (if there is overlapping, the most precise location is selected)
- Should create a Default record in case there's no match on location
- Can be associated with health checks

#### Geoproximity Routing Policy
- Ability to shift more traffic to resources based on the defined **bias**
- To change the size of the geographic region, specify bias values:
	- To expand (1 to 99), more traffic to the resource
	- To shrink (-1 to -99), less traffic to the resource
- Resources can be:
	- AWS resources (specify AWS region to calculate correct routing)
	- Non-AWS resources (specify latitude and longitude to calculate correct routing)
- You must use Route 53 Traffic Flow to use this feature

![[route-53-geoproximity-1.png]]
![[route-53-geoproximity-2.png]]

#### Multi-Value Routing Policy
- Use when you want to route traffic to multiple resources
- Can be associated with Health Checks return only values for healthy resources
- Up to 8 healthy records are returned for each Multi-Value query
- Multi-Value is not a substitute for having an ELB
- it's more powerful than Simple routing policy, because Simple doesn't support health checks

### Traffic Flow
- Simplify the process of creating and maintaining records in large and complex configuration
- Visual editor to manage complex routing decision trees
- Configurations can be saved as **Traffic Flow Policy** and can be applied to different Hosted Zones (different domain names)

### Health Checks
- HTTP Health Checks are only for public resources
- Thanks to health checks we can have Automated DNS Failover
	- Health checks that monitor an endpoint (application, sver, other AWS resources)
	- Health checks that monitor other health checks (Calculated Health Checks)
	- Health checks that monitor CloudWatch Alarms
- Health checks are integrated with CloudWatch

#### Monitor an endpoint
- 15 global health checkers will check the endpoint health
- You can set a threshold to evaluate if it's healthy or unhealthy (3 by default)
- You can set interval (30 seconds or 10 seconds)
- Supported protocol: HTTP, HTTPS, TCP
- If > 18% of health checkers report the endpoint is healthy, Route 53 considers it healthy, otherwise it's unhealthy
- Health Checks pass only when the endpoint responds with 2xx or 3xx status codes
- Health Checks can be setup to pass/fail based on the text in the first 5120 bytes of the response
- You have to configure your router/firewall to allow incoming requests from Route 53 Health Checkers

#### Calculated Health Checks
- Combine the results of multiple Health Checks into a single Health Check
- You can use OR, AND or NOT
- Can monitor up to 256 Child Health Checks
- You can specify how many of the health checks need to pass to make the parent pass

#### Private Hosted Zones Health Checks
- Route 53 health checkers are outiside the VPC, so they can't access private endpoints
- You can create a CloudWatch Metric and associate a CloudWatch Alarm, then create a Health Check that checks the alarm itself
