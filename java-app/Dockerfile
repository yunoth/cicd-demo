FROM openjdk:8-jre

copy ./target /usr/local/target/

EXPOSE 8080

ENTRYPOINT ["java","-jar","/usr/local/target/easy-notes-1.0.0.jar"]

