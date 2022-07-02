# https://github.com/lfromanini/sshWrapper
#
# ssh wrapper to retrieve sshpass arguments and connect to host
# reads [ LocalCommand sshpass ] parameters in file [ ~/.ssh/sshpass ]
#
# examples ( accepts regex similar to used in ~/.ssh/config ):
#
# Host my.ssh.server
# 	LocalCommand	sshpass -p thisIsThePassword
#
# Host *.local
# 	LocalCommand	sshpass -f path/to/fileContainingThePassword

# replace ssh only if sshpass is available
[ -z "$( whereis -b sshpass | awk '{ print $2 }' )" ] && printf "Can't use sshWrapper : missing sshpass\n" && return 1

function __sshwrapper::ssh()
{
	local readonly SSH=$( whereis -b ssh | awk '{ print $2 }' )

	local args=""
	local argType=""
	local argPass=""

	args=$( "${SSH}" "$@" -F ~/.ssh/sshpass -G 2>/dev/null | grep --max-count=1 --ignore-case "LocalCommand \+sshpass" | awk '{ $1=$2="" ; print $0 }' | sed 's/^[[:blank:]]*//' )

	if [ -z "${args}" ] ; then

		# no sshpass arguments set in ~/.ssh/sshpass file
		"${SSH}" "$@"

	else

		argType="${args:0:2}"
		argPass=$( echo "${args:2}" | sed 's/^[[:blank:]]*//' )

		# variable expansion
		if [ "${argType}" = "-f" ] ; then argPass=$( eval echo "${argPass}" ) ; fi

		command sshpass "${argType}""${argPass}" "${SSH}" "$@" -o PreferredAuthentications=password
	fi
}

alias ssh="__sshwrapper::ssh"
