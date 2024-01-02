# A. architecture

![](images/2024-01-02-18-34-59.png)

![](images/2024-01-02-18-38-52.png)
다른 AZ에 있는 public subnets for load balancer

![](images/2024-01-02-18-39-02.png)
다른 AZ에 있는 private subnet for ec2 & rds

0. internet gateway
1. vpc
2. classic load balancer
	- public subnets
	- security group
3. ec2
	- private subnets connected to nat gateway
	- security group
	- ebs
4. rds
	- private subnets connected to nat gateway
	- security group

# B. project structure

![](images/2024-01-02-18-50-38.png)

![](images/2024-01-02-18-34-23.png)


