FROM gcc:6 AS builder
RUN apt-get update && apt-get install -y sudo python-dev
RUN git clone https://github.com/facebook/watchman.git
WORKDIR /watchman

RUN git checkout v4.9.0
RUN ./autogen.sh && ./configure && make && make install

FROM node:latest
LABEL maintainer="fespinosa1"

RUN echo '\
deb http://httpredir.debian.org/debian jessie main contrib non-free \n\
deb-src http://httpredir.debian.org/debian jessie main contrib non-free \n\ 
\n\
deb http://security.debian.org/ jessie/updates main contrib non-free \n\
deb-src http://security.debian.org/ jessie/updates main contrib non-free\
' >> /etc/apt/sources.list.d/jessie.list

RUN apt-get update && apt-get install -y sudo libssl1.0.0 yarn

COPY --from=builder /usr/local/bin/watchman* /usr/local/bin/
COPY --from=builder /usr/local/lib/python2.7 /usr/local/lib/python2.7/
COPY --from=builder /usr/local/var /usr/local/var
COPY --from=builder /usr/local/share/doc /usr/local/share/doc

RUN echo "node ALL=NOPASSWD: /usr/local/bin/npm" > /etc/sudoers.d/node

USER node

RUN yarn global add expo-cli expo react-native

WORKDIR /app

EXPOSE 19000
EXPOSE 19001
EXPOSE 19002

ENTRYPOINT ["yarn"]

