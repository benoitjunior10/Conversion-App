FROM tomcat:10.1-jdk21-temurin AS build

WORKDIR /app
COPY . .

# Vérifie les bibliothèques nécessaires
RUN test -f lib/aspose-pdf-25.9.jar
RUN test -f lib/aspose-cells-25.12-jdk18.jar
RUN test -f lib/aspose-words-20.12-jdk17.jar

# Prépare l'application déployée en mode exploded
RUN rm -rf build-render && \
    mkdir -p build-render/ROOT/WEB-INF/classes build-render/ROOT/WEB-INF/lib build-render/ROOT/META-INF

# Copie les fichiers web
RUN cp -r web/. build-render/ROOT/

# Force le contexte racine
RUN printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' '<Context/>' > build-render/ROOT/META-INF/context.xml

# Garantit une page d'accueil explicite
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

# Compile les sources Java
RUN find src/java -name "*.java" > sources.txt && \
    javac -encoding UTF-8 \
          -cp "lib/*:/usr/local/tomcat/lib/*" \
          -d build-render/ROOT/WEB-INF/classes \
          @sources.txt

# Copie les bibliothèques
RUN cp lib/*.jar build-render/ROOT/WEB-INF/lib/

# Vérifications avant l'image finale
RUN test -f build-render/ROOT/index.jsp
RUN test -f build-render/ROOT/WEB-INF/web.xml
RUN test -f build-render/ROOT/WEB-INF/classes/controller/ConversionServlet.class

FROM tomcat:10.1-jre21-temurin

WORKDIR /usr/local/tomcat

RUN rm -rf webapps/*

# Déploiement à la racine
COPY --from=build /app/build-render/ROOT/ /usr/local/tomcat/webapps/ROOT/

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"0,/port=\\\"8080\\\"/s//port=\\\"${PORT:-10000}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
