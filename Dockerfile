FROM openjdk:11
LABEL Maintainer=Pardha
COPY target/psp-greet-hello-app-0.1.0.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]