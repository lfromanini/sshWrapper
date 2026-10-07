#!/usr/bin/env bash

export PATH_BIN="${BATS_TEST_DIRNAME}"/../bin
export PATH_MOCKS_DIR="${BATS_TEST_DIRNAME}"/mocks
export PATH_MOCKS="${PATH_MOCKS_DIR}:${PATH}"

export SSH_MOCK_PASSWORD_HOST="password.example.com"
export SSH_MOCK_FILE_HOST="file.example.com"
export SSH_MOCK_ENV_HOST="environment.example.com"
export SSH_MOCK_INVALID_OPTION_HOST="invalid-option.example.com"
export SSH_MOCK_OTHER_COMMAND_HOST="other-command.example.com"

export SSH_MOCK_PASSWORD="thisIsThePassword"
export SSH_MOCK_PASSWORD_FILE="${BATS_TEST_DIRNAME}"/support/password
