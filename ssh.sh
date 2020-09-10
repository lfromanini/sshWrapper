# ssh wrapper to retrieve sshpass arguments and connect to host
# reads [ LocalCommand sshpass ] parameters in file [ ~/.ssh/sshpass ]
#
# examples ( accepts regex similar to used in ~/.ssh/config ):
#
# Host my.ssh.server
# 	LocalCommand	sshpass -p thisIsThePassword
#
# Host *.local
# 	LocalCommand	sshpass -f fileContainingThePassword

function __sshWrapper__()
{
	local readonly SSH=`whereis -b "ssh" | awk '{ print $2 }'`
	local args=""

	args=`${SSH} "$@" -F ~/.ssh/sshpass -G 2>/dev/null | grep --max-count 1 --ignore-case "LocalCommand \+sshpass" | awk '{ print $3 $4 }'`

	if [ -z ${args} ] ; then	# no sshpass arguments set in ~/.ssh/sshpass file
		${SSH} "$@"
	else
		sshpass ${args} ${SSH} "$@" -o PreferredAuthentications=password
	fi
}

alias ssh="__sshWrapper__"
