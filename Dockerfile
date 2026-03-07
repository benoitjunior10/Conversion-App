FROM tomcat:10.1-jdk21-temurin AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends ant \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Vérifications utiles
RUN test -f lib/aspose-pdf-25.9.jar
RUN test -f lib/aspose-cells-25.12-jdk18.jar
RUN test -f lib/aspose-words-20.12-jdk17.jar
RUN test -f tools/org-netbeans-modules-java-j2seproject-copylibstask.jar

# Contexte déploiement racine
RUN printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' '<Context/>' > web/META-INF/context.xml

# Build NetBeans/Ant
RUN ant \
    -Dlibs.CopyLibs.classpath=/app/tools/org-netbeans-modules-java-j2seproject-copylibstask.jar \
    -Dj2ee.server.home=/usr/local/tomcat \
    clean dist

FROM tomcat:10.1-jre21-temurin

WORKDIR /usr/local/tomcat
RUN rm -rf webapps/*

COPY --from=build /app/dist/CV.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"0,/port=\\\"8080\\\"/s//port=\\\"${PORT:-10000}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
