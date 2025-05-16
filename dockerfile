FROM tomcat:9.0-jdk8-corretto
RUN rm -rf  /usr/local/tomcat/webapps/*
COPY /target/nextwork-web-project.war  /usr/local/tomcat/webapps/nextwork-web-project.war
EXPOSE 8080
CMD ["catalina.sh", "run"]