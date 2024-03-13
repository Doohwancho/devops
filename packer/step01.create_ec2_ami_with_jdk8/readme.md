
---\
How

```
terraform init
terraform apply --auto-approve
packer build openjdk8_ubuntu18_packer.pkr.hcl
terraform destroy --auto-approve
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
