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
# Host *.localdomain
# 	LocalCommand	sshpass -f path/to/fileContainingThePassword

function __sshwrapper::scp()
{
	local readonly SCP=$( whereis -b scp | command awk '{ print $2 }' )

	local args=""
	local argType=""
	local argPass=""
	local sshHost=""

	sshHost=$( echo "$@" | command awk -F ':' '/:/ { print $1 }' | command awk -F '@' '{ print $NF }' | command awk '{ print $NF }' )
	args=$( command ssh "${sshHost}" -F ~/.ssh/sshpass -G 2>/dev/null | command grep --max-count=1 --ignore-case "LocalCommand \+sshpass" | command awk '{ $1=$2="" ; print $0 }' | command sed 's/^[[:blank:]]*//' )

	if [ -z "${args}" ] || [ -z "$( whereis -b sshpass | command awk '{ print $2 }' )" ] ; then

		# no sshpass arguments set in ~/.ssh/sshpass file or sshpass not installed
		"${SCP}" "$@"
	else

		argType="${args:0:2}"
		argPass=$( echo "${args:2}" | command sed 's/^[[:blank:]]*//' )

		# variable expansion
		[ "${argType}" = "-f" ] && argPass=$( eval echo "${argPass}" )

		command sshpass "${argType}""${argPass}" "${SCP}" "$@"
	fi
}

function __sshwrapper::ssh()
{
	local readonly SSH=$( whereis -b ssh | command awk '{ print $2 }' )

	local args=""
	local argType=""
	local argPass=""

	args=$( "${SSH}" "$@" -F ~/.ssh/sshpass -G 2>/dev/null | command grep --max-count=1 --ignore-case "LocalCommand \+sshpass" | command awk '{ $1=$2="" ; print $0 }' | command sed 's/^[[:blank:]]*//' )

	if [ -z "${args}" ] || [ -z "$( whereis -b sshpass | command awk '{ print $2 }' )" ] ; then

		# no sshpass arguments set in ~/.ssh/sshpass file or sshpass not installed
		"${SSH}" "$@"
	else

		argType="${args:0:2}"
		argPass=$( echo "${args:2}" | command sed 's/^[[:blank:]]*//' )

		# variable expansion
		[ "${argType}" = "-f" ] && argPass=$( eval echo "${argPass}" )

		command sshpass "${argType}""${argPass}" "${SSH}" "$@" -o PreferredAuthentications=password
	fi
}

alias scp="__sshwrapper::scp"
alias ssh="__sshwrapper::ssh"
