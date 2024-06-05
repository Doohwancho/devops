## C.1. 내가 만든 어플리케이션 docker image 만들고 구동해 보기
### C.1.1. 프로젝트 env setup

사용할 테스트 스프링 프로젝트: https://github.com/parkseungchul/regiview 

```docker
vim Dockerfile 

FROM parkseungchul/centos8:package 
#dockerhub에서 어떤 이미지 가져올래?

ADD build.sh ./ 
#current dir에 있는 build.sh 파일을 컨테이너 안에 추가할게. 대신 ./build.sh을 만들어야 함.

RUN chmod 755 build.sh
#권한 줘야 실행가능하겠지?

RUN ./build.sh

ENTRYPOINT java -jar /app/regiView/target/regiView-1.0.jar -D FOREGROUND
#컨테이너 기동되면 자동으로 실행되는 명령어. 하나밖에 등록 못함

EXPOSE 8080
# 포트는 8080 포트 
```

```build.sh
mkdir -p /app/regiView
cd /app/regiView
git init
git pull https://github.com/parkseungchul/regiView
mvn install  #스프링이 maven 프로젝트면(pom.xml) 빌드하는 커멘드라인
```


### C.1.2. 프로젝트 -> 이미지 빌드
```commandline
sudo docker build -f Dockerfile -t regiview ./ //-f as file, -t as tag
sudo docker image ls //Dockerfile로 pull해서 만든 이미지가 보인다. 이름은 reviview
```

### C.1.3. ec2 환경에서 이미지 파일 실행하기

일단 저 이미지 파일을 docker hub에 올린 후, 도커 허브에서 이미지 받은 다음,

```commandline
sudo docker run -d --name regiv -e ip=regi -e port=5000 -p 8080:8080 --net regi_network  regiview //-e는 환경변수. ip=regi는 컨테이너 명. -e port는 regi 컨테이너 포트. -p 8080은 아까 Dockerfile에서 EXPOSE 8080했으니까. 
```



