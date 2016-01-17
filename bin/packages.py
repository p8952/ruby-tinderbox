#!/usr/bin/env python3

import hashlib, portage

def format_deps(dep_list):
    for item in list(dep_list):
        if "||" in item:
            dep_list.remove(item)
        if "?" in item:
            dep_list.remove(item)

    index = 0
    for item in list(dep_list):
        dep_list[index] = item.split('[')[0]
        dep_list[index] = portage.dep.dep_getcpv(item)
        index += 1

    index = 0
    for item in list(dep_list):
        if portage.getCPFromCPV(item):
            dep_list[index] = portage.getCPFromCPV(item)
        index += 1

    return dep_list

def join_deps(f_depend, f_rdepend, f_pdepend):
    return ';'.join(sorted(list(set(f_depend + f_rdepend + f_pdepend))))

def get_deps(cpv):
    depend, rdepend, pdepend = portage.portdb.aux_get(cpv, ['DEPEND', 'RDEPEND', 'PDEPEND'])
    depend = portage.dep.flatten(portage.dep.paren_reduce(depend, 1))
    rdepend = portage.dep.flatten(portage.dep.paren_reduce(rdepend, 1))
    pdepend = portage.dep.flatten(portage.dep.paren_reduce(pdepend, 1))
    return join_deps(format_deps(depend), format_deps(rdepend), format_deps(pdepend))

def format_output(cpv, slot, iuse, keyword):
    category, pkgname, version, revision = portage.catpkgsplit(cpv)
    sha1 = hashlib.sha1(open(PORTTREE.dbapi.findname(cpv), 'rb').read()).hexdigest()
    print(sha1 + ' ' + \
            category + ' ' + \
            pkgname + ' ' + \
            version + ' ' + \
            revision + ' ' + \
            slot + ' ' + \
            keyword, \
            end=' ')
    if 'ruby_targets_ruby20' in iuse:
        print('ruby20', end=' ')
    else:
        print('nil', end=' ')
    if 'ruby_targets_ruby21' in iuse:
        print('ruby21', end=' ')
    else:
        print('nil', end=' ')
    if 'ruby_targets_ruby22' in iuse:
        print('ruby22', end=' ')
    else:
        print('nil', end=' ')
    if 'ruby_targets_ruby23' in iuse:
        print('ruby23', end=' ')
    else:
        print('nil', end=' ')
    print(get_deps(cpv), end=' ')
    print()


PORTTREE = portage.db[portage.root]['porttree']
for cp in PORTTREE.dbapi.cp_all():
    slot_dict = {}
    for cpv in PORTTREE.dbapi.cp_list(cp):
        slot, iuse = PORTTREE.dbapi.aux_get(cpv, ['SLOT', 'IUSE'])
        slot_dict.setdefault(slot, {})[cpv] = (iuse)
    for slot, cpvd in slot_dict.items():
        if 'ruby_targets_' in iuse:

            cpvbs = (PORTTREE.dep_bestmatch(cp))
            if cpvbs:
                slot, iuse, keywords = PORTTREE.dbapi.aux_get(cpvbs, ['SLOT', 'IUSE', 'KEYWORDS'])
                if '~amd64' not in keywords and 'amd64' in keywords:
                    format_output(cpvbs, slot, iuse, 'amd64')

            cpvbu = portage.best(list(cpvd))
            if cpvbu:
                slot, iuse, keywords = PORTTREE.dbapi.aux_get(cpvbu, ['SLOT', 'IUSE', 'KEYWORDS'])
                if '~amd64' in keywords:
                    format_output(cpvbu, slot, iuse, '~amd64')
