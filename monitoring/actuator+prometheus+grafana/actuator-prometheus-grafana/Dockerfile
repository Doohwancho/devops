# gradle build
FROM gradle:7.4 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon --stacktrace

# openjdk8
FROM fabric8/java-alpine-openjdk8-jdk
COPY --from=build /home/gradle/src/build/libs/*.jar /app/app-with-metrics.jar
WORKDIR /app
EXPOSE 8080
CMD ["java", "-Dspring.profiles.active=local","-jar", "app-with-metrics.jar"]
