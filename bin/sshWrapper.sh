__sshWrapper()
(
	set -o errexit
	set -o nounset

	fSshWrapperConfig=${SSH_WRAPPER_CONFIG:-"${HOME}"/.ssh/sshpass}

	cmd=${1}
	shift

	case "${cmd}" in
		ssh|scp)
			# remove any alias or shell function that could take precedence over the executable when resolving the command with `command -v`
			unalias "${cmd}" 2>/dev/null || :
			unset -f "${cmd}" 2>/dev/null || :

			cmd=$( command -v "${cmd}" )
		;;

		*)
			return 2
		;;
	esac

	sshpassArgs=$( command ssh "$@" -F "${fSshWrapperConfig}" -G 2>/dev/null | awk 'tolower($1) == "localcommand" && $2 == "sshpass" { print $3 "\n" $4 ; exit }' )
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

	# sshpass not installed or no valid sshpass arg found in `${fSshWrapperConfig}`
	if [ -z "$( command -v sshpass || : )" ] || [ "${sshpassArgsValid}" = "false" ] ; then
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

	sshpass "${sshpassOption}${sshpassValue}" "${cmd}" "$@"
)

alias ssh='__sshWrapper ssh'
alias scp='__sshWrapper scp'
