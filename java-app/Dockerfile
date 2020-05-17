FROM openjdk:7

copy ./target /usr/local/

ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions","-XX:+UseCGroupMemoryLimitForHeap", "-Djava.security.egd=file:/dev/./urandom","-jar","/usr/local/target/easy-notes-1.0.0.jar"]

