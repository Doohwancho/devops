---\
Object

modularize web server 




---\
concept

a. apache-httpd\
b. nginx-nginx :soon:\
c. load-balancing :white_check_mark:\
d. reverse proxy :white_check_mark:\
e. ip_hash :white_check_mark:\
x. http -> https redirect(ssl 인증서)\
x. cache(static file)\
x. web application firewall\
x. nginx 2중화\
x. location /robots.txt 처리\
x. keepAlive(프록시 이중화)\
x. HAProxy




---\
todos

b-1. nginx vs httpd performance test :white_check_mark:

c-1. nginx로 load balancing 2 frontend server :white_check_mark:\
c-2. least_conn instead of round-robin + backup :white_check_mark:\
c-3. frontend & backend load balancing with backup server :white_check_mark:\
c-4. docker-compose에서 backend container ports:는 되는데 expose:는 안된건 nginx에서 depends_on: backend 안해줘서 안붙었던 것 :white_check_mark:\
c-5. localhost vs 127.0.0.1 on Home.js :white_check_mark:

d-1. rewrite로 /api/book 을 /book으로 redirect :white_check_mark:



---\
resources


b-1.[D113. Nginx vs Httpd 성능 테스트 (feat .사실 Docker 연습인 듯...)](https://www.youtube.com/watch?v=as97A61FNSs&list=PLogzC_RPf25Fx3eNZzxLVw3dOL7r4XIUk&index=15&ab_channel=SeungchulPark)

c-1. [docker-compose nginx로 2 frontend server load balancing](https://smoh.tistory.com/340) \
c-2. [least_conn && backup](https://cloud-oky.tistory.com/382) 

