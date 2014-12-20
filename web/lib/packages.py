import portage

portdb = portage.portdb
portdb.porttrees = [portdb.porttree_root]
for package in portdb.cp_all():
	slot_dict = {}
	for package_v in portdb.cp_list(package):
		slot, iuse, inherited = portdb.aux_get(package_v, ['SLOT', 'IUSE', 'INHERITED'])
		slot_dict.setdefault(slot, {})[package_v] = (iuse, inherited)
	for slot, package_v_dict in slot_dict.items():
		if 'ruby_targets_' in iuse:
			package_v_best = portage.best(list(package_v_dict))
			category, pkgname, version, revision = portage.catpkgsplit(package_v_best)
			print(category + ' ' + pkgname + ' ' + version + ' ' + revision + ' ' + slot, end=' ')
			if 'ruby_targets_ruby19' in iuse:
				print('ruby19', end=' ')
			else:
				print('nil', end=' ')
			if 'ruby_targets_ruby20' in iuse:
				print('ruby20', end=' ')
			else:
				print('nil', end=' ')
			if 'ruby_targets_ruby21' in iuse:
				print('ruby21', end=' ')
			else:
				print('nil', end=' ')
			print()
