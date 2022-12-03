---\
Goal


Modularize Monitoring



---\
Tools


a. springboot actuator + prometheus (server) + grafana(visualizer)\
b. springboot actuator + uptime-kuma(visualizer)

---\
Concepts

a-1. spring actuator + prometheus + grafana on docker-compose :white_check_mark:

b-1. setup uptime-kuma using docker-compose :white_check_mark:\
b-2. springboot actuator를 써서 주요 기능별로 healthchecker 만든 후, manager로 관리하는걸 uptime-kuma로 모니터링(latency+uptime)
