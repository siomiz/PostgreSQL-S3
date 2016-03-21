FROM alpine:latest

MAINTAINER Tomohisa Kusano <siomiz@gmail.com>

RUN apk -U add py-pip postgresql gnupg coreutils \
	&& pip install awscli

WORKDIR /workdir

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["echo", "* done!"]
