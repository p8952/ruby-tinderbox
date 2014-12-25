import portage

porttree = portage.db[portage.root]['porttree']
for cp in porttree.dbapi.cp_all():
    slot_dict = {}
    for cpv in porttree.dbapi.cp_list(cp):
        slot, iuse, keyword = porttree.dbapi.aux_get(cpv, ['SLOT', 'IUSE', 'KEYWORDS'])
        slot_dict.setdefault(slot, {})[cpv] = (iuse, keyword)
    for slot, cpvd in slot_dict.items():
        if 'ruby_targets_' in iuse:
            cpvb = portage.best(list(cpvd))
            category, pkgname, version, revision = portage.catpkgsplit(cpvb)
            print (category + ' ' + pkgname + ' ' + version + ' ' + revision + ' ' + slot, end=' ')

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
