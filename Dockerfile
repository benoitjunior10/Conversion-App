FROM tomcat:10.1-jdk21-temurin AS build

WORKDIR /app
COPY . .

# Vérifications des bibliothèques nécessaires
RUN test -f lib/aspose-pdf-25.9.jar
RUN test -f lib/aspose-cells-25.12-jdk18.jar
RUN test -f lib/aspose-words-20.12-jdk17.jar

# Prépare l'arborescence du WAR
RUN rm -rf build-render && \
    mkdir -p build-render/ROOT/WEB-INF/classes build-render/ROOT/WEB-INF/lib

# Copie les fichiers web
RUN cp -r web/. build-render/ROOT/

# Force le déploiement à la racine /
RUN printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' '<Context/>' > build-render/ROOT/META-INF/context.xml

# Compile les sources Java
RUN find src/java -name "*.java" > sources.txt && \
    javac -cp "lib/*:/usr/local/tomcat/lib/*" \
          -d build-render/ROOT/WEB-INF/classes \
          @sources.txt

# Copie les bibliothèques dans WEB-INF/lib
RUN cp lib/*.jar build-render/ROOT/WEB-INF/lib/

# Génère le WAR
RUN jar cfm ROOT.war src/conf/MANIFEST.MF -C build-render/ROOT .

FROM tomcat:10.1-jre21-temurin

WORKDIR /usr/local/tomcat

RUN rm -rf webapps/*

COPY --from=build /app/ROOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"0,/port=\\\"8080\\\"/s//port=\\\"${PORT:-10000}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
