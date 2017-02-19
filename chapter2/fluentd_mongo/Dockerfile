FROM fluent/fluentd:v0.14.12
MAINTAINER alice_k106@naver.com
WORKDIR /home/fluent
ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH
USER root
RUN apk update && \
apk add musl-dev gcc make ruby-dev && \
fluent-gem install fluent-plugin-mongo
EXPOSE 24284
USER fluent
CMD exec fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
