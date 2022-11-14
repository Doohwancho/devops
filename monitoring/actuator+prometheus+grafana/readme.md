## Spring Boot Prometheus Grafana

Running Spring Boot App Monitoring suite with Prometheus and Grafana

### Starting

```shell
docker-compose up -d --build
```

### Stopping
```shell
docker-compose down
```

### Links

| App  | URL  |
|---|---|
| App | [http://localhost:8080/](http://localhost:8080/) |
| Prometheus | [http://localhost:9090/graph](http://localhost:9090/graph) |
| Grafana  | [http://localhost:3000](http://localhost:3000)  |
| Spring Boot Actuator | [http://localhost:8080/actuator/metrics](http://localhost:8080/actuator/metrics)

# trial

1. docker compose up -d --build
2. [http://localhost:9090/graph](http://localhost:9090/graph) -> 프로메테우스 접속
3. 프로메테우스에 status 메뉴에 targets 클릭 -> endpoint에 http://demo-app:8080/actuator/prometheus 가 떠 있는걸 확인 가능하다.
4. prometheus.graph -> expression에서 내가 원하는 metrics 클릭 -> execute 하면 결과를 볼 수 있다. 근데 Prometheus에서 보는게 ui가 별로니까, grafana로 본다.
5. http://localhost:3000/ 에서 admin/admin 치고 로그인 후,
6. add datasource -> prometheus 선택. url에 http://localhost:9090 입력 후 save
7. dashboard -> add panel -> Metric에서 원하는 지표 선택 -> Apply



#What is Spring Actuator?

스프링 모니터링할 때 필요한 서버 정보 보여줌.

http://localhost:8080/actuator/ 하면, 어느 정보의 url을 보고싶은지 리스트가 나옴.\
ex. localhost:8080/actuator/env 를 하면, {"status":"UP"} 이렇게 서버가 떠있다고 나옴.

---
actuator에서 제공하는 정보의 default는 http://localhost:8080/actuator/metrics 이거인데,
아래의 정보를 얻을 수 있음.\
{"names":["jvm.classes.unloaded","tomcat.sessions.active.current","jvm.buffer.count","jvm.memory.used","tomcat.threads.busy","tomcat.sessions.alive.max","jvm.gc.live.data.size","jvm.buffer.total.capacity","jvm.memory.max","jvm.memory.committed","jvm.gc.pause","process.files.open","jvm.threads.states","tomcat.sessions.active.max","http.server.requests","jvm.buffer.memory.used","process.start.time","logback.events","tomcat.global.sent","process.files.max","jvm.gc.memory.promoted","tomcat.global.request.max","system.load.average.1m","tomcat.global.request","jvm.gc.max.data.size","system.cpu.count","tomcat.global.received","tomcat.sessions.created","jvm.threads.daemon","system.cpu.usage","jvm.gc.memory.allocated","tomcat.threads.config.max","tomcat.sessions.expired","jvm.threads.live","jvm.threads.peak","tomcat.global.error","process.uptime","tomcat.sessions.rejected","tomcat.threads.current","process.cpu.usage","jvm.classes.loaded"]}

---
대신 이게 보기가 UI상 불편하니까, prometheus + grafana 쓰는 것.
spring actuator에 프로메테우스를 연결하면,

http://localhost:8080/actuator/prometheus
했을 때, 얻을 수 있는 정보가 나오는데, 이걸 prometheus가 받고 grafana가 visualize 함.

---

spring actuator + admin + security 으로도 서버 모니터링이 가능은 하나,\
모니터링 관점에서 Prometheus + grafana가 더 범용적으로 쓰인다 (세련되고 편리한 UI 때문).\
그러나 프로메테우스에서는 위 방법에서 할 수 있는 heap dump, thread dump같은 액션은 취할 수 없다.



# What is Prometheus?

웹서버, 디비 모니터링 + 특정 조건 발생 시 담당자에게 경고(alert) 기능 



# What is Grafana?


Prometheus에서 받은 데이터 visualizer

ex1. https://play.grafana.org/d/000000012/grafana-play-home?orgId=1 \
ex2. https://ce.grafana.net/public-dashboards/326d9aa2606b4efea25f4458a4c3f065?orgId=0&refresh=1m

---
ex1.의 경우, 이게 공식 데모 페이지인가 봄.
온갖 종류의 graph가 있네.

server request(서버 별로)+memory, cpu usage + response time + 트래픽 시계열 정보 보여주네

alert기능이 있네? 이건 Prometheus기능인데 그저 front기능만 보조해주는건가?


---
ex2는 https://godbolt.org/ 에서 서버 정보를 시각화 해서 보여줌.
payload가 시간별로 몇개가 오는지,
response time(TPS)는 얼마나 되는지,
서버에 인스턴스가 몇개 떠있는지,
어느 language가 요청이 더 많이 오는지 
CPU usage,
cache hit 도 보여줌.


오!


