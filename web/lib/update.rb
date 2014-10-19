require 'gems'
require 'pmap'

def packages_clear(db)

	packages = db[:packages]
	packages.delete

end

def packages_update(db)

	packages = db[:packages]
	packages_txt = `python3 lib/packages.py`

	db.transaction do
		packages_txt.lines.peach do |line|
			category, name, version, revision, slot, r19_target, r20_target, r21_target = line.split(' ')
			gem_version = Gems.info(name)['version']
			packages.insert(
				:category => category,
				:name => name,
				:version => version,
				:revision => revision,
				:slot => slot,
				:identifier => category + '/' + name + '-' + version + '-' + revision,
				:gem_version => gem_version,
				:r19_target => r19_target,
				:r20_target => r20_target,
				:r21_target => r21_target,
			)
		end
	end

end
