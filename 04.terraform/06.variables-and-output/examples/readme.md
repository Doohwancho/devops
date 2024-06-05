
1. variables.tf: main.tf에 넣을 변수의 타입과 description, default value(optional)를 적는 곳
2. terraform.tfvars: variables.tf에 정의한 타입에 따라 실제 값을 적는 곳. (ex. password)
3. outputs.tf: terraform apply이후 뱉는 값. 이걸 input 삼아 다른 테라폼이나 프로그램 실행 가능

