# === Etapa 1: construir el WAR con Maven ============================
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Carpeta de trabajo dentro del contenedor
WORKDIR /app

# Copiamos solo el pom primero (para cachear dependencias)
COPY pom.xml .

# Descargamos dependencias (esto se cachea si el pom no cambia)
RUN mvn -B dependency:go-offline

# Ahora copiamos el código fuente
COPY src ./src

# Compilamos y generamos el WAR
RUN mvn -B clean package -DskipTests

# === Etapa 2: imagen final con Tomcat ================================
FROM tomcat:9.0-jdk17

# Borramos las apps de ejemplo de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiamos el WAR construido en la etapa anterior
# OJO: el nombre debe coincidir con <finalName> en tu pom.xml (sintetica.war)
COPY --from=build /app/target/sintetica.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]


