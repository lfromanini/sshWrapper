__sshWrapper()
(
	set -o errexit
	set -o nounset

	cmd=${1}
	shift

	case "${cmd}" in
		ssh|scp)
			cmd=$( whereis -b "${cmd}" | awk '{ print $2 }' )
		;;

		*)
			return 2
		;;
	esac

	sshpassCmd=$( whereis -b sshpass | awk '{ print $2 }' )
	sshpassArgs=$( command ssh "$@" -F "${HOME}/.ssh/sshpass" -G 2>/dev/null | awk 'tolower($1) == "localcommand" && $2 == "sshpass" { print $3 "\n" $4 ; exit }' )
	sshpassOption=$( printf '%s' "${sshpassArgs}" | awk 'NR == 1' )
	sshpassValue=$( printf '%s' "${sshpassArgs}" | awk 'NR == 2' )
	sshpassArgsValid=true

	case "${sshpassOption}" in
		-p|-f)
			[ -n "${sshpassValue}" ] || sshpassArgsValid=false
		;;

		-e)
			[ -z "${sshpassValue}" ] || sshpassArgsValid=false
		;;

		*)
			sshpassArgsValid=false
		;;
	esac

	# sshpass not installed or no valid sshpass arg found in ~/.ssh/sshpass
	if [ -z "${sshpassCmd}" ] || [ "${sshpassArgsValid}" = "false" ] ; then
		"${cmd}" "$@"
		return $?
	fi

	[ "${sshpassOption}" = "-f" ] && {
		# shellcheck disable=SC2088     # Tilde does not expand in quotes. Use `$HOME`.
		case "${sshpassValue}" in
			'~/'*)
				sshpassValue="${HOME}/${sshpassValue#~/}"
			;;
		esac

		sshpassValue=$( printf '%s' "${sshpassValue}" | envsubst )
	}

	"${sshpassCmd}" "${sshpassOption}${sshpassValue}" "${cmd}" "$@"
)

alias ssh='__sshWrapper ssh'
alias scp='__sshWrapper scp'
