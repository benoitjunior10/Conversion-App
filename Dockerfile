FROM tomcat:10.1-jdk21-temurin AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends ant \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Vérifications des bibliothèques nécessaires
RUN test -f lib/aspose-pdf-25.9.jar
RUN test -f lib/aspose-cells-25.12-jdk18.jar
RUN test -f lib/aspose-words-20.12-jdk17.jar

# Force le déploiement à la racine au lieu de /CV
RUN printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' '<Context/>' > web/META-INF/context.xml

# Build Ant du projet NetBeans/Tomcat
RUN ant -Dj2ee.server.home=/usr/local/tomcat clean dist

FROM tomcat:10.1-jre21-temurin

WORKDIR /usr/local/tomcat

# Nettoie les apps par défaut
RUN rm -rf webapps/*

# Copie le WAR généré
COPY --from=build /app/dist/CV.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"0,/port=\\\"8080\\\"/s//port=\\\"${PORT:-10000}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]