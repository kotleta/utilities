FROM perl:5.20
MAINTAINER Sveta Kotleta <sveta@svetakotleta.ru>


RUN apt-get update && apt-get install -y libssl-dev cpanminus
RUN cpanm Net::SSLeay EV AnyEvent Text::CSV AnyEvent::HTTP Scalar::Util

WORKDIR /usr/src/ktl
COPY . /usr/src/ktl

CMD sh -i
