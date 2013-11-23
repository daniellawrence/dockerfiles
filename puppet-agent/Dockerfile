FROM ubuntu:12.04
MAINTAINER Danny Lawrence <dannyla@linux.com>
RUN echo "deb http://au.archive.ubuntu.com/ubuntu precise main universe multiverse" > /etc/apt/sources.list
RUN apt-get update -qq
RUN apt-get install -y wget
RUN wget -q http://apt.puppetlabs.com/puppetlabs-release-precise.deb -O /tmp/puppetlabs.deb
RUN dpkg -i /tmp/puppetlabs.deb
RUN apt-get update
RUN apt-get -y install puppet 
RUN echo "puppet agent -t --server \${PUPPETMASTER:-puppet}" > ~/.bashrc

CMD ["/bin/bash"]
