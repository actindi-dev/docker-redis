#############################################################################
#
# build
# docker build -t localhost:5000/debian-wheezy-redis .
#
# run
# ID=$(docker run --privileged -d -t --name 'redis1' localhost:5000/debian-wheezy-redis)
# IP=$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" $ID)
# echo $ID $IP
#############################################################################

FROM debian:wheezy
MAINTAINER TAHARA Yoshinori <tahara@actindi.net>

WORKDIR /tmp

# apt-get
ENV DEBIAN_FRONTEND noninteractive
ADD sources.list /etc/apt/sources.list
RUN apt-get update && apt-get install -y apt-utils && apt-get dist-upgrade -y \
 && apt-get install -y openssh-server sudo build-essential zsh vim lv wget rsyslog

# Time zone
RUN echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure tzdata

# locale
RUN echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen \
    && apt-get update \
    && apt-get install locales \
    && update-locale LANG=ja_JP.UTF-8 \
    && . /etc/default/locale


# user
RUN useradd -d /home/ancient -m -s /bin/zsh ancient && mkdir /home/ancient/.ssh
ADD dot.ssh /home/ancient/.ssh
ADD dot.zshrc /home/ancient/.zshrc
RUN echo 'ancient ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && chown -R ancient:ancient /home/ancient \
    && chmod -R go-xrw /home/ancient/.ssh

# redis
RUN mkdir -p /opt/redis/src \
 && cd /opt/redis/src \
 && wget http://download.redis.io/releases/redis-2.8.19.tar.gz \
 && tar xvf redis-2.8.19.tar.gz && cd redis-2.8.19 \
 && make \
 && make PREFIX=/opt/redis install \
 && mkdir /opt/redis/conf \
 && mkdir /opt/redis/data
ADD redis.conf /opt/redis/conf/
ADD sentinel.conf /opt/redis/conf/
ADD redis-server /etc/init.d/redis-server
ADD redis-sentinel /etc/init.d/redis-sentinel
RUN chmod +x /etc/init.d/redis-server /etc/init.d/redis-sentinel \
 && chown -R ancient:ancient /opt


# cleanup
RUN apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*


# ssh
EXPOSE 22 6379 26379

ADD start.sh /start.sh
CMD /start.sh
