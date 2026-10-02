FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY Projet_wallet-main/wallet-service/pom.xml pom.xml
COPY Projet_wallet-main/wallet-service/src src
RUN mvn -q -DskipTests package
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /src/target/wallet-service-0.0.1-SNAPSHOT.jar /app/app.jar
COPY deploy/render-java-entrypoint.sh /app/start.sh
EXPOSE 10000
ENTRYPOINT ["/bin/sh", "/app/start.sh"]
