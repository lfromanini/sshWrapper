#!/usr/bin/env bash

export MOCK_SSHPASS_COMMAND_NOT_FOUND=false

function command( )
{
	[[ "${1}" == "-v" ]] && case "${2}" in
	ssh|scp)
		printf '%s/%s\n' "${PATH_MOCKS_DIR}" "${2}"
		return 0
	;;

	sshpass)
		if [[ "${MOCK_SSHPASS_COMMAND_NOT_FOUND}" == "true" ]] ; then
			printf '\n'
			return 1
		else
			printf '%s/%s\n' "${PATH_MOCKS_DIR}" "${2}"
			return 0
		fi
	;;
	esac

	builtin command "$@"
}
