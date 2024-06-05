# Reat-Springboot Book 프로젝트

### 스프링부트

- Springboot ^2.0
- JPA
- MySQL (H2)
- Maven
- Lombok


## AWS 배포하려면

root 접속 -> sudo passwd root -> su root 접속
apt update
apt install git (설치 되어있음)
apt install maven
apt install docker.io
apt install docker-compose

### 배포 명령

- mvn compile
- mvn clean package
- docker-compose up --build -d (백그라운드 실행)