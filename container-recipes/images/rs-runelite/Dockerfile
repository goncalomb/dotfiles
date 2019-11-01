ARG RECIPE_REUSE_CONTAINER
ARG RECIPE_HOST_DISPLAY
ARG RECIPE_HOST_ALSA

# FROM openjdk:12-alpine
# FROM openjdk:11.0.4-jre
# Exception in thread "main" java.lang.NoClassDefFoundError: Could not initialize class net.runelite.launcher.SplashScreen
#	at net.runelite.launcher.Launcher.main(Launcher.java:300)

FROM alpine:3.10

WORKDIR root

RUN apk add --no-cache openjdk11-jre fontconfig ttf-dejavu

RUN wget https://github.com/runelite/launcher/releases/download/2.0.0/RuneLite.jar

ENTRYPOINT ["java"]
CMD ["-jar", "RuneLite.jar", "--nojvm"]
