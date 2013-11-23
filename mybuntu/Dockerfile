FROM ubuntu:12.04
MAINTAINER Danny Lawrence <dannyla@linux.com>
RUN echo "deb http://au.archive.ubuntu.com/ubuntu precise main universe multiverse" > /etc/apt/sources.list
RUN apt-get update -qq
RUN apt-get install wget vim build-essential -y

CMD ["/bin/bash"]
