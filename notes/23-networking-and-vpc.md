# Networking and VPC

## CIDR (IPv4)
- Classless Inter-Domain Routing - a method for allocating IP addresses
- Can be used in Security Groups rules and AWS networking in general
- They help to define an IP address range:
	- WW.XX.YY.ZZ/32 -> one IP
	- 0.0.0.0/0 -> all IPs
	- 192.168.0.0/26 -> 192.168.0.0 - 192.168.0.63
- The second part of the IP is called **Subnet Mask**
- Subnet Mask defines how many bits can change in the IP

![[subnet-mask-ip.png]]

## Public vs Private IP (IPv4)
- The Internet Assigned Numbers Authority (IANA) established certain blocks of IPv4 addresses for the use of private (LAN) and public (Internet) addresses
- **Private IP** can only allow certain values:
	- 10.0.0.0 - 10.255.255.255 (10.0.0.0/8) in big networks
	- 172.16.0.0 - 172.31.255.255 (172.16.0.0/12) AWS default VPC is in this range
	- 192.168.0.0 - 192.168.255.255 (192.168.0.0/16) in home networks
- All the rest of the IP addresses are public

## VPC in AWS - IPv4
- You can have multiple VPCs in an AWS region (max 5 per region - soft limit)
- Because VPC is private, only private IP ranges are allowed
- Your VPC CIDR should not overlap with your other networks

### Default VPC
- All new AWS accounts have a default VPC
- New EC2 instances are launched into the default VPC if no subnet is specified
- Default VPC has internet connectivity and all EC2 instances inside it have public IPv4 addresses
- We also get a public and a private IPv4 DNS for our EC2 instances

### Subnet
- AWS reserves 5 IP addresses  (first 4 and last 1) in each subnet
- These IP addresses are not available for use and can't be assigned to an EC2 instance
- **Exam Tip**, if you need 29 addresses for EC2 instances:
	- You can't choose a subnet of size /27 (=32 IP addresses, 32-5 = 27 < 29)
	- You need to chose a subnet of size /26 (=64 IP addresses, 64-5 = 59 > 29), in this way you took the subnets reserved addresses into account

## Internet Gateway (IGW)
- Allow resources (e.g. EC2 instances) in a VPC to connect to the internet
- It scales horizontally and is highly available and redundant
- Must be created separately from a VPC
- One VPC can only be attached to one IGW and vice versa
- IGW needs Route Tables in order to allow internet access

![[igw-route-table.png]]

## Bastion Hosts
- We can use Bastion Host to SSH into our private EC2 instance (private subnet)
- The bastion is in the public subnet, which is then connected to all other private subnets
- Bastion Host security group must be tightened
- **Exam tip**: make sure the bastion host only has port 22 traffic from the IP address you need, not from the security groups of your other EC2 instances

![[bastion-host.png]]

## NAT Instace
- Outdate, NAT Gateway is a better solution
- NAT = Network Address Translation
- Allows EC2 instances in private subnets to connect  to the internet
- Must be launched in a public subnet
- Must disable EC2 setting: **Source/Destination Check**
- Must have Elastic IP attached to it
- Route Tables must be configured to route traffic from private subnets to the NAT instance
- It's not highly available. If you want to have HA, you need to create multiple NAT instances
- Bandwidth depends on EC2 instance type
- You have to manage security groups

![[nat-instance.png]]

## NAT Gateway
- AWS managed NAT, higher bandwidth, high availability, no administration
- Pay per hour for usage and bandwidth
- Created in a specific AZ, uses an Elastic IP
- Can't be used by EC2 instance in the same subnet
- Requires an IGW
- 5 Gbps of bandwidth with automatic scaling up to 45 Gbps
- No security group to manage
- **High Availability**
	- NAT Gateway is resilient within a single AZ
	- Must create multiple NAT Gateways if you want multiple AZs for fault-tolerance

![[nat-gateway.png]]

## DNS Resolution in VPC
- **DNS Resolution (enableDnsSupport)**
	- Decides if DNS resolution from Route53 Resolver server is supported for the VPC
	- True (default): it queries the Amazon Provider DNS Server at 169.254.169.253 or the reserved IP address at the base of the VPC IPv4 network range plus two
	- False: you have to create your own custom DNS server if you want to resolve DNS
- **DNS Hostnames (enableDnsHostname)**
	- By default is true for default VPC, and false for newly created VPCs
	- Won't do anything unless enableDnsSupport=true
	- If true, assigns public hostname to EC2 instance if it has a public IPv4
	- The private hostname is always assigned, wheather the option is true or false

## NACL and Security Groups
- NACL are stateless
- Security Groups are stateful

### Network Access Control List (NACL)
- NACL are like a firewall which controll traffic from and to subnets
- One NACL per subnet, new subnets are assigned the Default NACL
- You define NACL Rules:
	- Rules have a number (1 - 32766)
	- First rule match will drive the decision
	- Example: if you define #100 ALLOW 10.0.0.10/32 and #200 DENY 10.0.0.10/32, the IP address will be allowed, because 100 has higher precedence than 200
- Newly created NACLs will deny everything
- NACL are a great way of blocking a specific IP address at the subnet level
- Default NACL rule allows everything in and out

### Ephemeral Ports
- Clients connect to a defined port, and expect a response on an ephemeral port
- When you define NACL rules for subnet, you need to take this into consideration because NACL are stateless

![[nacl-ephemeral-ports.png]]

## VPC Reachibility Analyzer
- A network diagnostic tool that troubleshoots network connectivity between two endpoints in your VPC
- It builds a model of the network configuration, then checks the reachability based on these configurations (it doesn't send packets)
- If the destination is
	- **Reachable**: it produces hob-by-hop details of the virtual network path
	- **Not reachable**: it identifies the blocking components
- Use cases: troubleshoot connectivity issues, ensure network configuration is as intended

## VPC Peering
- Privately connect two VPCs using AWS' network
- Make them behave as if they were in the same network
- Must not have overlapping CIDRs
- VPC Peering connection is NOT transitive (must be established for each VPC that need to communicate with one another)
- You must update route tables in each VPC's subnets to ensure EC2 instances can communicate with each other
- You can create VPC Peering connection between VPCs in different AWS accounts/regions
- You can reference a security group in a peered VPC(works cross accounts - same region)

## VPC Endpoints
- Every AWS service is publicly exposed (public URL)
- VPC Endpoints (powered by AWS PrivateLink) allow you to connect to AWS services using a private network instead of using the public internet
- They're redundant and scale horizontally
- They remove the need of IGW and NATGW to access AWS services from a VPC
- In case of issue:
	- Checke DNS Setting Resolution is activated in your VPC
	- Check Route Tables

### Type of endpoints
- **Interface Endpoints**
	- Provisions an ENI (private IP address) as an entry point (must attach a security group)
	- Supports most AWS services
- **Gateway Endpoints**
	- Provisions a gateway and must be used as a target in a route table
	- Supports only S3 and DynamoDB

## VPC Flow Logs
- Capture information about IP traffic going to your interfaces:
	- VPC Flow Logs
	- Subnet Flow Logs
	- Elastic Network Interface Flow Logs
- Help to monitor and troubleshoot connectivity issues
- Flow logs data can go to S3 and CloudWatch Logs
- Captures network information from AWS managed interfaces too: ELB, RDS, ElastiCache, Redshift, WorkSpaces, NATGW, Transit Gateway, etc...
- Can be used for analytics on usage patterns or malicious behavior
- You can query VPC flow logs using Athena on S3 or CloudWatch Logs Insights
- The records contain information about IP, ports, and Action (success or failure of the request due to SG/NACL)

## AWS Site-to-Site VPN
- **Virtual Private Gateway (VGW)**
	- VPN concentrator on the AWS side of the VPN connection
	- VGW is created and attached to the VPC from which you want to create the Site-to-Site VPN connection
	- Possibility to customize the ASN (Autonomous System Number)
- **Customer Gateway (CGW)**
	- Software application or physical device on customer side of the VPN connection

#### Site-to-Site Connections
- **Customer Gateway Device (on-premises)**
	- Use public internet-routable IP address for your Customer Gateway device
	- If it's behind a NAT device that's enabled for NAT traversal (NAT-T), use the public IP addresso f the NAT device
- **Important step**: enable **Route Propagation** for the Virtual Private Gateway  in the route table that is associated with your subnets
- If you need to ping your EC2 instances from on-premises, mae sure you add the ICMP protocol on the inbound of your security groups

![[site-to-site-vpn.png]]

### AWS VPN CloudHub
- Provide secure communication between multiple sites, if you have multiple VPN connections
- Low-cost solution for primary or secondary network connectivity between different locations (VPN only)
- It's a VPN connection so it goes over the public internet
- To set it up, connect multiple VPN connections on the same VGW, setup dynamic routing and configure route tables

![[vpn-cloudhub.png]]

## Direct Connect (DX)
- Provides a dedicated private connection from a remote network to your VPC
- Dedicated connection must be setup between your DC and AWS DIrect Connect locations
- You need to setup a Virtual Private Gateway on your VPC
- Access public resources (S3) and private (EC2) on same connection
- Supports both IPv4 and IPv6
- Use cases:
	- Increase bandwidth throughput - working with large data sets, lower cost
	- More consistent network experience - applocations using real-time data feeds
	- Hybrid Environments (on premises + cloud)

![[direct-connect-diagram.png]]

### Direct Connect Gateway
- If you want to setup a Direct Connect to one or more VPC in many different regions (same account), you must use a Direct Connect Gateway

![[direct-connect-gateway.png]]

### Connection Types
- **Dedicated Connections**: 1 Gbps, 10 Gbps and 100 Gbps
	- Physical ethernet port dedicated to a customer
	- Request made to AWS first, then completed by AWS Direct Connect Partners
- **Hosted Connections**: 50 Mbps, 500 Mbps, to 10 Gbps
	- Connection requests are made via AWS Direct Connect Parners
	- Capacity can be added or removed on demand
	- 1, 2, 5, 10 Gbps available at select AWS Direct Connect Partners
- Lead times are often longer than 1 month to establish a new connection

### Encryption
- Data in transit is not encrypted but is private
- AWS Direct Connect + VPN provides an IP sec-encrypted private connection

### Resiliency
![[direct-connect-resiliency.png]]

### Direct Connect + Site to Site VPN
- In case Direct Connect fails, you can set up a backup Direct Connect connection (expensive), or a Site-to-Site VPN connection

## Transit Gateway
- For having transitive peering between thousands of VPC and on-premises, hub-and-spoke connection
- Regional resource, can work cross-region
- Share cross-account using Resource Access Manager
- You can peer Transit Gateways across regions
- Route Tables: limit which VPC can talk with other VPC
- Works with Direct Connect Gateway, VPN connections
- Supports IP Multicast (not supported by any other AWS service)
- You can share Direct Connect between multiple accounts by attaching it to a Transit Gateway

## VPC - Traffic Mirroring
- Allows you to capture and inspect network traffic in your VPC
- Route the traffic to security appliances that you manage
- Capture the traffic from (source) ENIs
- Capture the traffic to (target) ENI or Network Load Balancer
- Capture all packets or capture the packets of your interest (optionally truncate packets)
- Source and Target can be in the same VPC or different VPCs (VPC peering)
- Use cases: content inspection, threat monitoring, troubleshooting

![[vpc-mirroring.png]]

## IPv6
- IPv4 was designed to provide 4.3 billion addresses (they'll be exhausted soon)
- IPv6 is designed to provide 3.4 x 10^38 unique IP addresses
- Every IPv6 address is public and Internet routable (no private range)
- Format is x.x.x.x.x.x.x.x (x is hexadecimal, range can be from 0000 to ffff)

### IPv6 in VPC
- IPv4 cannot be disabled for your VPC and subnets
- You can enable IPv6 (for public addresses) to operate in dual-stack mode
- Your EC2 instances will get at least a private internal IPv4 and a public IPv6
- They can communicate using either IPv4 or IPv6 to the internet through an Internet Gateway

## Egress-only Internet Gateway
- Used for IPv6 only
- Similar to a NAT Gateway but for IPv6
- Allows instances in your VPC outbound connections over IPv6 while preventing the internet to initiate an IPv5 connection to your instances
- You must update the Route Tables

## Networking Cost
- Use Private IP instead of Public IP to save money on network cost and have better performance
- Use same AZ for maximum savings (at the cost of not having high availability)

![[networking-cost.png]]

### Minimize egress traffic cost
- **Egress traffic**: outbound traffic (from AWS to outisde)
- **Ingress traffic**: inbound traffic (from outside to AWS)
- Try to keep the traffic inside AWS to minimize costs
- Direct Connect location that are co-located in the same AWS Region result in lower cost for egress network

### S3 Data Transfer Pricing
- S3 ingress: free
- S3 egress: $0.09 per GB
- S3 Transfer Acceleration: from $0.04 to $0.08 to add on top of Data Transfer cost
- S3 to CloudFront: free
- CloudFront to Internet: $0.085 per GB
- S3 Cross Region Replication: $0.02 per GB

![[s3-pricing.png]]

### NAT Gateway vs Gateway VPC Endpoint Pricing
- NAT Gateway: $0.045 per hour + $0.045 per GB processed
- VPC Endpoint: $0.01 per GB transfer in/out

![[nat-vs-vpc-endpoint-pricing.png]]

## AWS Network Firewall
- Protect your entire VPC
- From Layer4 to Layer 7 protection
- Any direction, you can inspect:
	- VPC to VPC traffic
	- Outbound to internet
	- Inbound from internet
	- To/from Direct Connect and Site-to-Site VPN
- Internally it uses AWS Gateway Load Balancer
- Rules can be centrally managed cross-account by AWS Firewall Manager to apply to many VPCs
- Supports 1000s of rules, you can filter by:
	- IP and port
	- Protcol
	- Stateful domain list rule groups
	- General pattern matching using regex
- Traffic filtering: Allow, drop, or alert for the traffic that matches the rules
- Active flow inspection to protect against network threats with intrusion prevention capabilities (like Gateway Load Balancer nut is all managed by AWS)
- Send logs of rule matches to S3, CloudWatch Logs, Kinesis Data Firehose

