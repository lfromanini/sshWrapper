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

function __sshWrapper__()
{
	local readonly SSH=$( whereis -b ssh | awk '{ print $2 }' )

	local args=""
	local argType=""
	local argPass=""

	args=$( ${SSH} "$@" -F ~/.ssh/sshpass -G 2>/dev/null | grep --max-count 1 --ignore-case "LocalCommand \+sshpass" | awk '{ $1=$2="" ; print $0 }' | sed 's/^[[:blank:]]*//' )

	if [ -z "${args}" ] ; then

		# no sshpass arguments set in ~/.ssh/sshpass file
		${SSH} "$@"

	else

		argType=${args:0:2}
		argPass=$( echo ${args:2} | sed 's/^[[:blank:]]*//' )

		# variable expansion
		[ "${argType}" = "-f" ] && argPass=$( eval echo ${argPass} ) || true

		sshpass ${argType}${argPass} ${SSH} "$@" -o PreferredAuthentications=password
	fi
}

alias ssh="__sshWrapper__"
