FROM fluent/fluentd:latest
MAINTAINER alice_k106@naver.com
WORKDIR /home/fluent
ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH
USER root
RUN fluent-gem install fluent-plugin-mongo
EXPOSE 24284
USER fluent
CMD exec fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
