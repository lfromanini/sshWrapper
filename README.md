# sshWrapper

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![GitHub stars](https://img.shields.io/github/stars/lfromanini/sshWrapper)](https://github.com/lfromanini/sshWrapper/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/lfromanini/sshWrapper)](https://github.com/lfromanini/sshWrapper/issues)

An SSH wrapper that retrieves `sshpass` credentials and uses them to log in to remote hosts.

```text
         _  __        __                               
 ___ ___| |_\ \      / / __ __ _ _ __  _ __   ___ _ __ 
/ __/ __| '_ \ \ /\ / / '__/ _` | '_ \| '_ \ / _ \ '__|
\__ \__ \ | | \ V  V /| | | (_| | |_) | |_) |  __/ |   
|___/___/_| |_|\_/\_/ |_|  \__,_| .__/| .__/ \___|_|   
                                |_|   |_|              
```

## Usage

`sshWrapper` works with both `ssh` and `scp`. When `ssh` or `scp` is called, `sshWrapper` looks for a matching `LocalCommand sshpass` entry in `~/.ssh/sshpass`.

For example:

```config
Host my.ssh.server
    LocalCommand sshpass -p thisIsThePassword

Host *.localdomain
    LocalCommand sshpass -f path/to/fileContainingThePassword
```

The original command:

```bash
ssh [args] my.ssh.server [more args]
```

is transformed into:

```bash
sshpass -pthisIsThePassword ssh [args] my.ssh.server [more args]
```

or, when using a password file:

```bash
sshpass -fpath/to/fileContainingThePassword ssh [args] my.ssh.server [more args]
```

The same logic applies to `scp`.

If no matching `sshpass` entry is found, or if `sshpass` is not installed, the original `ssh` or `scp` command is executed unchanged.

### Configuration

The `Host` patterns in `~/.ssh/sshpass` are evaluated by OpenSSH, including wildcard patterns such as `*` and `?`.

Only `LocalCommand` entries containing `sshpass` are used by `sshWrapper`. Other options in `~/.ssh/sshpass` are ignored and should instead be placed in the regular `~/.ssh/config` file.

For example:

```config
Host my.ssh.server
    LocalCommand sshpass -p thisIsThePassword

Host *.localdomain
    LocalCommand sshpass -f path/to/fileContainingThePassword
```

For `-f`, the password file path supports `~`, `$HOME`, `$PWD`, and other environment variables through `envsubst`.

## Installation

### Bash and Zsh

1. Download `sshWrapper.sh`:

```bash
curl -O https://raw.githubusercontent.com/lfromanini/sshWrapper/main/bin/sshWrapper.sh
```

2. Source the file from your shell configuration:

```bash
$EDITOR ~/.bashrc
# and/or
$EDITOR ~/.zshrc
```

Add:

```bash
source path/to/sshWrapper.sh
```

3. Reload your shell configuration:

```bash
source ~/.bashrc
# or
source ~/.zshrc
```

That's it.

### Requirements

`sshWrapper` is written using POSIX shell syntax, but it depends on the following external commands:

- `ssh`
- `scp`
- `sshpass`
- `awk`
- `envsubst`
- `whereis`

Most of these tools are commonly available by default on Linux systems, but `sshpass` usually needs to be installed separately.

## Security Warning

Because of the potential for abuse, the `~/.ssh/sshpass` file must have strict permissions: it should be readable and writable only by its owner.

For example:

```bash
chmod 600 ~/.ssh/sshpass
```

This method requires storing passwords in an unencrypted plain-text file.

Anyone who can read `~/.ssh/sshpass` can obtain the passwords stored in it. For this reason, using SSH public key authentication is strongly recommended whenever possible.

`sshWrapper` is intended for situations where password authentication is required or otherwise preferred.
