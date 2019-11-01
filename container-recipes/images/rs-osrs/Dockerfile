ARG RECIPE_REUSE_CONTAINER
ARG RECIPE_HOST_DISPLAY
ARG RECIPE_HOST_ALSA

FROM openjdk:8-alpine

WORKDIR root

RUN apk add --no-cache p7zip libxml2-utils fontconfig ttf-dejavu

RUN wget https://www.runescape.com/downloads/OldSchool.dmg
RUN 7z e OldSchool.dmg \
    "Old School RuneScape/Old School RuneScape.app/Contents/Java/jagexappletviewer.jar" \
    "Old School RuneScape/Old School RuneScape.app/Contents/Info.plist"

ADD entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
