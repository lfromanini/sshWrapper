#!/usr/bin/env bats

function setup() {
	load 'support/common.bash'

	export PATH="${PATH_MOCKS}"

	# shellcheck disable=SC1091     # SC1091: Not following: (error message here)
	source "${PATH_BIN}/sshWrapper.sh"
}

function teardown() { true ; }

@test "sshpass -pthisIsThePassword ssh -p 2222 password.example.com" {
	run __sshWrapper ssh -p 2222 "${SSH_MOCK_PASSWORD_HOST}"

	[[ "${status}" == 0 ]]
	[[ "${output}" == "mocked-sshpass -p${SSH_MOCK_PASSWORD} ${PATH_MOCKS_DIR}/ssh -p 2222 ${SSH_MOCK_PASSWORD_HOST}" ]]
}

@test "sshpass -f password-file ssh -p 2222 file.example.com" {
	run __sshWrapper ssh -p 2222 "${SSH_MOCK_FILE_HOST}"

	[[ "${status}" == 0 ]]
	[[ "${output}" == "mocked-sshpass -f${SSH_MOCK_PASSWORD_FILE} ${PATH_MOCKS_DIR}/ssh -p 2222 ${SSH_MOCK_FILE_HOST}" ]]
}

@test "sshpass -pthisIsThePassword scp -P 2222 password.example.com:/tmp/file ." {
	run __sshWrapper scp -P 2222 "${SSH_MOCK_PASSWORD_HOST}:/tmp/file" .

	[[ "${status}" == 0 ]]
	[[ "${output}" == "mocked-sshpass -p${SSH_MOCK_PASSWORD} ${PATH_MOCKS_DIR}/scp -P 2222 ${SSH_MOCK_PASSWORD_HOST}:/tmp/file ." ]]
}

@test "sshpass -f password-file scp -P 2222 file.example.com:/tmp/file ." {
	run __sshWrapper scp -P 2222 "${SSH_MOCK_FILE_HOST}:/tmp/file" .

	[[ "${status}" == 0 ]]
	[[ "${output}" == "mocked-sshpass -f${SSH_MOCK_PASSWORD_FILE} ${PATH_MOCKS_DIR}/scp -P 2222 ${SSH_MOCK_FILE_HOST}:/tmp/file ." ]]
}

@test "ssh -p 2222 no-password.example.com" {
	run __sshWrapper ssh -p 2222 "${SSH_MOCK_NO_PASSWORD_HOST}"

	[[ "${status}" == 0 ]]
	[[ "${output}" == "mocked-ssh -p 2222 ${SSH_MOCK_NO_PASSWORD_HOST}" ]]
}

@test "ssh -p 2222 invalid-option.example.com" {
	run __sshWrapper ssh -p 2222 "${SSH_MOCK_INVALID_OPTION_HOST}"

	[[ "${status}" == 0 ]]
	[[ "${output}" == "mocked-ssh -p 2222 ${SSH_MOCK_INVALID_OPTION_HOST}" ]]
}

@test "ssh -p 2222 other-command.example.com" {
	run __sshWrapper ssh -p 2222 "${SSH_MOCK_OTHER_COMMAND_HOST}"

	[[ "${status}" == 0 ]]
	[[ "${output}" == "mocked-ssh -p 2222 ${SSH_MOCK_OTHER_COMMAND_HOST}" ]]
}

@test "ssh -p 2222 password.example.com when sshpass is not installed" {
	export SSH_MOCK_SSH_PASS_INSTALLED=false

	run __sshWrapper ssh -p 2222 "${SSH_MOCK_PASSWORD_HOST}"

	[[ "${status}" == 0 ]]
	[[ "${output}" == "mocked-ssh -p 2222 ${SSH_MOCK_PASSWORD_HOST}" ]]
}
