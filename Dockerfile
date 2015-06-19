FROM scratch
MAINTAINER Peter Wilmott <p@p8952.info>
ADD cache/stage3-amd64.tar.bz2 /

RUN mkdir /ruby-tinderbox
ADD bin/* /ruby-tinderbox/

RUN /ruby-tinderbox/provision.sh
