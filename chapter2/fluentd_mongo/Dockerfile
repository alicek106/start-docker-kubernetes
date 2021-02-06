FROM fluent/fluentd:v1.12
LABEL maintainer=alice_k106@naver.com
USER root

RUN apk update && \
  apk add musl-dev gcc make ruby-dev && \
  fluent-gem install fluent-plugin-mongo

EXPOSE 24284
USER fluent
CMD exec fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
