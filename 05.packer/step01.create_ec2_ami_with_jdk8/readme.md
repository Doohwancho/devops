
---\
How

```
terraform init
terraform apply
packer build openjdk8_ubuntu18_packer.pkr.hcl
terraform destroy
```


---\
What


1. create custom vpc, subnet, igw, rt, etc.
	- because subnet-id is required when creating custom ami.
2. create custom ami
	- openjdk8-zulu
	- ec2 instance class type: "m7g.2xlarge"
		- 8core, 32GiB RAM
	- ami-059e7332a087320a3
		- arm64
		- aws graviton3 processor


---\
주의점


1. aws custom ami를 만들면, ec2 cloudwatch가 깔려있지 않다. -> ec2 monitoring을 별도로 구축해야 한다.
