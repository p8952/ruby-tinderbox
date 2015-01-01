import portage

def format_output(cpv, slot, iuse, keyword):
    category, pkgname, version, revision = portage.catpkgsplit(cpv)
    print (category + ' ' + pkgname + ' ' + version + ' ' + revision + ' ' + slot + ' ' + keyword, end=' ')
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

porttree = portage.db[portage.root]['porttree']
for cp in porttree.dbapi.cp_all():
    slot_dict = {}
    for cpv in porttree.dbapi.cp_list(cp):
        slot, iuse = porttree.dbapi.aux_get(cpv, ['SLOT', 'IUSE'])
        slot_dict.setdefault(slot, {})[cpv] = (iuse)
    for slot, cpvd in slot_dict.items():
        if 'ruby_targets_' in iuse:

            cpvbs = (porttree.dep_bestmatch(cp))
            if cpvbs:
                slot, iuse, keywords = porttree.dbapi.aux_get(cpvbs, ['SLOT', 'IUSE','KEYWORDS'])
                if '~amd64' not in keywords and 'amd64' in keywords:
                    format_output(cpvbs, slot, iuse, 'amd64')

            cpvbu = portage.best(list(cpvd))
            if cpvbu:
                slot, iuse, keywords = porttree.dbapi.aux_get(cpvbu, ['SLOT', 'IUSE', 'KEYWORDS'])
                if '~amd64' in keywords:
                    format_output(cpvbu, slot, iuse, '~amd64')
