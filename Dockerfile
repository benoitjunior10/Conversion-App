FROM tomcat:10.1-jre21-temurin

RUN rm -rf /usr/local/tomcat/webapps/* \
 && mkdir -p /usr/local/tomcat/webapps/ROOT \
 && printf 'ok' > /usr/local/tomcat/webapps/ROOT/health.txt \
 && printf '<h1>OK Render</h1>' > /usr/local/tomcat/webapps/ROOT/index.html

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"0,/port=\\\"8080\\\"/s//port=\\\"${PORT:-10000}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
