FROM scratch
MAINTAINER Peter Wilmott <p@p8952.info>
ADD cache/stage3-amd64.tar.bz2 /

RUN mkdir /ruby-tinderbox
ADD conf/provision.sh /ruby-tinderbox/
ADD conf/make.conf /ruby-tinderbox/
ADD tinder.sh /ruby-tinderbox/
ADD repoman.sh /ruby-tinderbox/
ADD web/lib/packages.py /ruby-tinderbox/
ADD web/lib/deps.py /ruby-tinderbox/

RUN sed -i -e 's/sudo //g' /ruby-tinderbox/provision.sh
RUN /ruby-tinderbox/provision.sh
