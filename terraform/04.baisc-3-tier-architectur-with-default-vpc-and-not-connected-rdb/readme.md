# what

[](./architecture.png)

generic 3-tier-architecture

- EC2 instances
- S3 bucket
- RDS instance
- Load balancer
- Route 53 DNS config

# how to run?

1. main.tf에서 route 53에 자신이 구입한 domain url 입력
2. terraform init
3. terraform plan
4. terraform apply
5. dns website(ex. godaddy)에서 dns server를 aws route 53에 ns server 4개로 변경
6. 주의! - DNS changes can take up to 48 hours to propagate fully around the world. During this time, some users might still be directed to the old server.
7. 따라서 route53의 A record인 load balancer의 dns 주소창을 입력하여 서버가 잘 작동하는지 확인


# Todo

1. backend + provider config
2. EC2 instance
3. S3 Bucket
4. VPC
5. Subnet
6. Security groups + rules
7. Application Load Balancer
8. ALB target group + attachment
9. Route 53 zone + record
10. RDS instance



