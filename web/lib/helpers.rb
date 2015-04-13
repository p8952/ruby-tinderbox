class String
	def camelcase(delimiter = ' ')
		split(delimiter).map(&:capitalize).join(delimiter)
	end
end

# module Archive::Tar::Minitar
# 	class << self
# 		def pack_file(entry, outputter)
# 			outputter = outputter.tar if outputter.kind_of?(Archive::Tar::Minitar::Output)
#
# 			stats = {}
#
# 			if entry.kind_of?(Hash)
# 				name = entry[:name]
#
# 				entry.each { |kk, vv| stats[kk] = vv unless vv.nil? }
# 			else
# 				name = entry
# 			end
#
# 			name = name.sub(%r{\./}, '')
# 			stat = File.stat(name)
# 			stats[:mode]   ||= stat.mode
# 			stats[:mtime]  ||= stat.mtime
# 			stats[:size]   = stat.size
#
# 			if RUBY_PLATFORM =~ /win32/
# 				stats[:uid]  = nil
# 				stats[:gid]  = nil
# 			else
# 				stats[:uid]  ||= stat.uid
# 				stats[:gid]  ||= stat.gid
# 			end
#
# 			case
# 			when File.file?(name)
# 				outputter.add_file_simple(name, stats) do |os|
# 					stats[:current] = 0
# 					yield :file_start, name, stats if block_given?
# 					File.open(name, "rb") do |ff|
# 						until ff.eof?
# 							stats[:currinc] = os.write(ff.read(4096))
# 							stats[:current] += stats[:currinc]
# 							yield :file_progress, name, stats if block_given?
# 						end
# 					end
# 					yield :file_done, name, stats if block_given?
# 				end
# 			when dir?(name)
# 				yield :dir, name, stats if block_given?
# 				outputter.mkdir(name, stats)
# 			end
# 		end
# 	end
# end
