require 'archive/tar/minitar'
require 'docker'
require 'gems'
require 'logger'
require 'net/scp'
require 'net/ssh'
require 'pmap'
require 'sequel'
require 'sinatra/base'

require_relative 'lib/ci'
require_relative 'lib/helpers'
require_relative 'lib/models'
require_relative 'lib/packages'

class RubyTinderbox < Sinatra::Base
	Dir.glob('./routes/*.rb') { |f| require f }
end
