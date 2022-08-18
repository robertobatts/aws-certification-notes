# CloudFront and Global Accelerator

## CloudFront
- It's a CDN (Content Delivery Network)
- Improves read performance, content is cached at the edge
- 216 Point of Presence globally (edge locations)
- DDos protection, integration with Shield, AWS Web Application Firewall
- Can expose external HTTPS and can talk to internal HTTPS backends

![[cloudfront-high-level.png]]

### Origins
- **S3 bucket**
	- For distributing files and caching them at the edge
	- Enanched security with CloudFront Origin Access Identity (OAI)
	- CloudFront can also be used as an ingrass to upload files to S3
- **Custom Origin (HTTP)**
	- Application Load Balancer
	- EC2 instance
	- S3 website
	- Any HTTP backend you want

Using S3 allow to restrict the access to only CloudFront through OAI. If OAI is not used (like in EC2 or ALB in which is not available) then the access of the resource must be public.

![[cloudfront-s3-origin.png]]

![[cloudfront-ec2-alb-origin.png]]

### Geo Restriction
- You can restrict who can access your distribution by whitelisting or blacklisting countries
- The country is determined using a 3rd party Geo-IP database
- Use case: Copyright Laws to control access to content

### CloudFront vs S3 Cross Region Repliaction
- CloudFront
	- Global Edge network
	- Files are cached for a TTL
	- Great for static content that must be available everywhere
- S3 Cross Region Replication
	- Must be setup for each region you want replication to happen
	- Files are updated in near real-time
	- Read only
	- Great for dynamic content that needs to be available in low-latency in a few regions

### CloudFront Signed URL and Signed Cookies
- You want to distribute paid shared content to premium users over the world
- We can use CloudFront Segned URL/Cookie. We attach a policy with:
	- URL expiration
	- IP ranges to access the data from
	- Trusted signers (which AWS accounts can create signed URLs)
- How long should the URL be valid for?
	- Shared content: make it short (a few minutes)
	- Private content: you can make it last for years
- Signed URL = access to individual files (one signed URL per file)
- Signe Cookies = access to multiple files (one signed cookie for many files)

### CloudFront Signed URL vs S3 Pre-Signed URL
- CloudFront Signed URL:
	- Allow access to a path, no matter the origin, it can also be an EC2 instance url
	- Account wide key-pair, only the root can manage it
	- Can filter by IP, path, date, expiration
	- Can leverage caching features
- S3 Pre-Signed URL:
	- Issue a request as the person who pre-signed the URL
	- Uses the IAM krey of the signing IAM principal
	- Limited lifetime

### CloudFront Pricing
- The cost of data out per edge location depends on the location
- The more data you transfer, the lower is the cost per GB
- Cheaper locations are US and EU

#### Price Classes
- You can reduce the number of edge locations for ost reduction
- Three price classes:
	- Price Class All: all regions, best performance
	- Price Class 200: most regions, but excludes the most expensive regions
	- Price Class 100: only the least expensive regions

### Multiple Origin
- To route to different kind of origins based on the content type
- Based on path pattern (e.g. /* , /api/* )

![[cloudfront-multiple-origin.png]]

### Origin Groups
- To increase high availability and do failover
- Origin Group: one primary and one secondary origin
- If the primary origin fails, the second one is used

### Field Level Encryption
- Protect user sensitive information through application stack
- Adds an additional layer of security along with HTTPS
- Sensitive information encrypted at the edge close to user
- Uses asymmetric encryption
- Usage:
	- Specify set of fields in POST requests that you want to be encrypted (up to 10 fields)
	- Specify the public key to encrypt them


## AWS Global Accelerator
**Unicast IP**: one server holds one IP address
**Anycast IP**: all servers hold the same IP address, and the client is routed to the nearest one

- Leverage the AWS internal network to route to your application
- 2 Anycast IP are created for your application
- The Anycast IP send traffic directly to Edge Locations
- The Edge locations send the traffic to your application
- Works with Elastic IP, EC2, ALB, NLB, public or private
- Consistent Performance
	- Intelligent routing to lowest latency and fast regional failover
	- No issue with client cache (because the IP doesn't change)
	- Internal AWS network
- Health Checks
	- Global Accelerator performs a health check of your applications
	- Helps make your application globale (failover less than 1 minute for unhealthy)
	- Great for disaster recovery thanks to the health checks
- Security
	- Only 2 external IP need to be whitelisted by your client
	- DDoS protection thanks to AWS Shield

### AWS Global Accelerator vs CloudFront
- They both use the AWS global network and its edge locations around the world
-  Both services integrate with AWS Shield for DDoS protection
- CloudFront
	- Improves performance for both cacheable content and dynamic content
	- Content is served at the edge (except for when the cache has to be updated because of TTL)
- Global Accelerator
	- Improve performance for a wide range of applications over TCP or UDP
	- Proxying packets at the edge to applications running in one or more AWS Regions
	- Good fit for non-HTTP use cases, such as gaming, IoT, or Voice ofer IP
	- Good for HTTP use cases that require static IP addresses
