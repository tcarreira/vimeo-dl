FROM golang:1.19.2-alpine AS build

WORKDIR /app
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 go build -o /vimeo-dl .


############################################################

FROM alpine:3.17 AS no-ffmpeg
COPY --from=build /vimeo-dl /usr/bin/vimeo-dl
WORKDIR /downloads
ENTRYPOINT [ "vimeo-dl" ]

############################################################

FROM lscr.io/linuxserver/ffmpeg:5.1.2 AS vimeo-dl-custom
COPY --from=build /vimeo-dl /usr/bin/vimeo-dl
COPY vimeo-dl-custom.sh /usr/bin/vimeo-dl-custom.sh
WORKDIR /downloads
ENTRYPOINT [ "/usr/bin/vimeo-dl-custom.sh" ]

############################################################

FROM lscr.io/linuxserver/ffmpeg:5.1.2 AS with-ffmpeg
COPY --from=build /vimeo-dl /usr/bin/vimeo-dl
WORKDIR /downloads
ENTRYPOINT [ "vimeo-dl" ]

