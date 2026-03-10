FROM tomcat:10.1-jre21-temurin

WORKDIR /usr/local/tomcat

RUN rm -rf webapps/*

COPY web/ /usr/local/tomcat/webapps/ROOT/
RUN rm -f /usr/local/tomcat/webapps/ROOT/META-INF/context.xml
RUN printf 'ok' > /usr/local/tomcat/webapps/ROOT/health.txt

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"0,/port=\\\"8080\\\"/s//port=\\\"${PORT:-10000}\\\"/\" conf/server.xml && catalina.sh run"]
