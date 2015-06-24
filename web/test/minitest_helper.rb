gem 'minitest'
require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

clear_packages
package = File.read('test/test-logs/1/package').lines.to_a.each(&:strip!)
Package.create(
	sha1: package[0],
	category: package[1],
	name: package[2],
	version: package[3],
	revision: package[4],
	slot: package[5],
	identifier: package[6],
	amd64_keyword: package[7],
	r19_target: package[8],
	r20_target: package[9],
	r21_target: package[10],
	r22_target: package[11],
	gem_version: package[12]
)
update_build('test/test-logs/*/*/builds/*')

MiniTest.after_run { clear_packages }
