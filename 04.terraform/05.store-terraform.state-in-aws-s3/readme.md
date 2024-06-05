remote cloud인 s3에 terraform state를 저장해두고, main.tf에서 값을 불러올 떄, aws_s3_bucket.terraform_state.bucket 이런식으로 불러오는 방법.

혼자 프로젝트할 때 쓰는 방법은 아니고,

여러 개발자가 협업할 때, terraform state를 한곳에 관리하고 싶은데, 유료인 terraform cloud는 쓰고싶지 않을 때 사용하는 방법
