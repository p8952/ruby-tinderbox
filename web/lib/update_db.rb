def db_clear(db)

	packages = db[:packages]
	packages.delete

end

def db_update(db)

	packages = db[:packages]
	packages_txt = `python lib/targets.py`

	db.transaction do
		packages_txt.lines.each do |line|
			category, name, version, revision, slot, r19_target, r20_target, r21_target = line.split(' ')
			packages.insert(
				:category => category,
				:name => name,
				:version => version,
				:revision => revision,
				:slot => slot,
				:identifier => category + '/' + name + '-' + version + '-' + revision + ':' + slot,
				:r19_target => r19_target,
				:r20_target => r20_target,
				:r21_target => r21_target,
			)
		end
	end

end
