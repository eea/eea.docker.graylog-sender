FROM alpine:3.9


RUN apk add --no-cache ca-certificates bash curl coreutils 

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["run"]

