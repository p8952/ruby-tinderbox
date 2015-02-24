# Ruby Tinderbox

Framework for testing Ruby related packages in Gentoo Linux.

## Usage

Build the docker base image:

	./conf/get_stage3.sh
    docker build -t gentoo/ruby-tinderbox .

Run the tinderbox scripts against a single package:

    docker run gentoo/ruby-tinderbox /ruby-tinderbox/tinder.sh \
		category/package-version-revision

Run the tinderbox scripts against multiple packages:

	docker run gentoo/ruby-tinderbox /ruby-tinderbox/tinder.sh \
		category/package-version-revision \
		category/package-version-revision \
		category/package-version-revision

By default the tinderbox script will build binary packages which are discarded
when the container is removed. If you test multiple packages at once these will
be reused where possible for each of the packages.

If you want to take advantage of binary packages after a container has been
removed you can persist them by bind mounting a directory on the host to
`/usr/portage/packages`.

	docker run -v /tmp/bincache:/usr/portage/packages gentoo/ruby-tinderbox \
		/ruby-tinderbox/tinder.sh category/package-version-revision

# [Ruby Tinderbox Web](http://ruby-stats.p8952.info/)

Web interface and build server built on top of the Ruby Tinderbox framework.

# License

Ruby Tinderbox is [licensed under the AGPL](https://github.com/p8952/ruby-tinderbox/blob/master/LICENSE).

Some of the [javascript used by the web interface](https://github.com/p8952/ruby-tinderbox/tree/master/web/public/js)
is licensed under the Mozilla Public License and MIT licenses. This is noted in
the headers of the relevant files.
