
FROM tomcat:9.0-jdk17

# Borramos las aplicaciones de ejemplo de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiamos tu WAR y lo desplegamos como ROOT
# OJO: aquí usamos exactamente el nombre de tu WAR
COPY target/sintetica.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]

