# A. architecture

![](images/2024-01-02-18-34-59.png)
\+ elasticache connected to ec2?

---
![](images/2024-01-11-18-17-35.png)
다른 AZ에 있는 public subnets for load balancer

![](images/2024-01-11-18-17-50.png)
다른 AZ에 있는 private subnet for ec2 & rds & elasticache

0. iam
	- AmazonSSMManagedInstanceCore policy for access to private ec2 using aws session manager
1. internet gateway
2. vpc
3. classic load balancer
	- public subnets
	- security group
4. ec2
	- private subnets connected to nat gateway
	- security group
	- ebs
5. rds
	- private subnets connected to nat gateway
	- security group
6. elasticache
	- private subnets
	- security group

# B. project structure

![](images/2024-01-02-18-50-38.png)

![](images/2024-01-02-18-34-23.png)


# C. resources
- elasticache terraform example - https://github.com/umotif-public/terraform-aws-elasticache-redis/blob/main/examples/redis-basic/main.tf
