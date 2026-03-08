FROM tomcat:10.1-jdk21-temurin AS build

WORKDIR /app
COPY . .

# Vérifie les bibliothèques
RUN test -f lib/aspose-pdf-25.9.jar
RUN test -f lib/aspose-cells-25.12-jdk18.jar
RUN test -f lib/aspose-words-20.12-jdk17.jar

# Prépare une application ROOT décompressée
RUN rm -rf build-render && \
    mkdir -p build-render/ROOT/WEB-INF/classes build-render/ROOT/WEB-INF/lib

# Copie les ressources web
RUN cp -r web/. build-render/ROOT/

# Supprime le context.xml embarqué pour éviter toute ambiguïté
RUN rm -f build-render/ROOT/META-INF/context.xml

# Ajoute un web.xml minimal pour la page d'accueil
RUN mkdir -p build-render/ROOT/WEB-INF && \
    printf '%s\n' \
'<?xml version="1.0" encoding="UTF-8"?>' \
'<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"' \
'         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' \
'         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"' \
'         version="6.0">' \
'    <welcome-file-list>' \
'        <welcome-file>index.jsp</welcome-file>' \
'    </welcome-file-list>' \
'</web-app>' \
> build-render/ROOT/WEB-INF/web.xml

# Compile le code Java
RUN find src/java -name "*.java" > sources.txt && \
    javac -encoding UTF-8 \
          -cp "lib/*:/usr/local/tomcat/lib/*" \
          -d build-render/ROOT/WEB-INF/classes \
          @sources.txt

# Copie les JAR dans l'application
RUN cp lib/*.jar build-render/ROOT/WEB-INF/lib/

# Vérifications avant l'image finale
RUN test -f build-render/ROOT/index.jsp
RUN test -f build-render/ROOT/WEB-INF/web.xml
RUN printf 'ok' > build-render/ROOT/health.txt

FROM tomcat:10.1-jre21-temurin

WORKDIR /usr/local/tomcat

RUN rm -rf webapps/*

COPY --from=build /app/build-render/ROOT/. /usr/local/tomcat/webapps/ROOT/

# Vérifications dans l'image finale
RUN test -f /usr/local/tomcat/webapps/ROOT/index.jsp
RUN test -f /usr/local/tomcat/webapps/ROOT/health.txt

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"0,/port=\\\"8080\\\"/s//port=\\\"${PORT:-10000}\\\"/\" conf/server.xml && echo '=== ROOT FILES ===' && find /usr/local/tomcat/webapps/ROOT -maxdepth 3 -type f | sort && echo '=== START TOMCAT ===' && catalina.sh run"]
