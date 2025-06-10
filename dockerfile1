FROM maven:3.9.9-amazoncorretto-8-alpine AS builder
WORKDIR /app
COPY . /app/
RUN mvn clean
RUN mvn package

FROM tomcat:9.0-jdk8-corretto
RUN rm -rf  /usr/local/tomcat/webapps/*
COPY  --from=builder /app/target/nextwork-web-project.war  /usr/local/tomcat/webapps/nextwork-web-project.war
EXPOSE 8080
CMD ["catalina.sh", "run"]