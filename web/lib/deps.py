import portage, sys

def format_depend(dep_list):
    for item in list(dep_list):
        if "||" in item: dep_list.remove(item)
        if "?" in item: dep_list.remove(item)

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

def join_depend(f_depend, f_rdepend, f_pdepend):
    return ' '.join(sorted(list(set(f_depend + f_rdepend + f_pdepend))))

cpv = sys.argv[1]
depend, rdepend, pdepend = portage.portdb.aux_get(cpv, ['DEPEND', 'RDEPEND', 'PDEPEND'])
depend = portage.dep.flatten(portage.dep.paren_reduce(depend, 1))
rdepend = portage.dep.flatten(portage.dep.paren_reduce(rdepend, 1))
pdepend = portage.dep.flatten(portage.dep.paren_reduce(pdepend, 1))
all_depend = join_depend(format_depend(depend), format_depend(rdepend), format_depend(pdepend))

print (all_depend)
