# Ruby Tinderbox

Scripts for testing Ruby related packages in Gentoo Linux.

## Usage

    vagrant up
    vagrant ssh
    cd /vagrant
    ./tinder.sh category/package-version-revision
    
# [Ruby Stats](http://ruby-stats.p8952.info/)

Web interface and build server built on top of the above mentioned scripts.

Maintains a database of the build results of all Ruby related packages.

# License

Ruby Tinderbox and the bundled Ruby Stats are both [licensed under the AGPL](https://github.com/p8952/ruby-tinderbox/blob/master/LICENSE).

Some of the [javascript used by Ruby Stats](https://github.com/p8952/ruby-tinderbox/tree/master/web/public/js) is licensed under the Mozilla Public License and MIT licenses. This is noted in the headers of the relevent files.
