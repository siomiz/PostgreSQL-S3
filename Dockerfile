FROM postgres:latest

MAINTAINER Tomohisa Kusano <siomiz@gmail.com>

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y curl

RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python
RUN pip install awscli

WORKDIR /workdir

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["echo", "* done!"]
