# sshWrapper

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![GitHub stars](https://img.shields.io/github/stars/lfromanini/sshWrapper)](https://github.com/lfromanini/sshWrapper/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/lfromanini/sshWrapper)](https://github.com/lfromanini/sshWrapper/issues)
[![CI](https://github.com/lfromanini/sshWrapper/actions/workflows/ci.yaml/badge.svg)](https://github.com/lfromanini/sshWrapper/actions/workflows/ci.yaml)

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

Host my.other.ssh.localdomain
    LocalCommand sshpass -f path/to/fileContainingThePassword

Host *.localdomain
    LocalCommand sshpass -e
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

or, when using the `SSHPASS` environment variable:

```bash
sshpass -e ssh [args] my.ssh.server [more args]
```

> With `-e`, `sshpass` reads the password from the `SSHPASS` environment variable. See the [`sshpass` man page](https://linux.die.net/man/1/sshpass) for more information.

The same logic applies to `scp`.

If no matching `sshpass` entry is found, or if `sshpass` is not installed, the original `ssh` or `scp` command is executed unchanged.

### Configuration

The `Host` patterns in `~/.ssh/sshpass` are evaluated by OpenSSH, including wildcard patterns such as `*` and `?`.

Only `LocalCommand` entries containing `sshpass` are used by `sshWrapper`. Other options in `~/.ssh/sshpass` are ignored and should instead be placed in the regular `~/.ssh/config` file.

For example:

```config
Host my.ssh.server
    LocalCommand sshpass -p thisIsThePassword

Host my.other.ssh.localdomain
    LocalCommand sshpass -f path/to/fileContainingThePassword

Host *.localdomain
    LocalCommand sshpass -e
```

For `-f`, the password file path supports `~`, `$HOME`, `$PWD`, and other environment variables through `envsubst`.

For `-e`, `sshpass` reads the password from the `SSHPASS` environment variable. The variable must be set in the environment of the shell running `ssh` or `scp`.

#### Limitations

##### Passwords containing spaces

Passwords containing spaces are not supported when using the `-p` option in `~/.ssh/sshpass`.

The `LocalCommand` configuration is parsed using `awk`, so whitespace in the password cannot be reliably preserved. If the password contains spaces, use the `-f` option and store the password in a file instead:

```config
Host my.ssh.server
    LocalCommand sshpass -f ~/.ssh/my-password
```

This also follows the recommended approach documented by [`sshpass`](https://linux.die.net/man/1/sshpass), which recommends using a password file when possible.

##### Password file paths containing spaces

Password file paths containing spaces are also not supported by the current `LocalCommand` parsing.

As a workaround, use a path without spaces, for example by creating a symbolic link:

```bash
ln -s "/path/with spaces/password" ~/.ssh/my-password
```

Then configure `sshpass` to use the path without spaces:

```config
Host my.ssh.server
    LocalCommand sshpass -f ~/.ssh/my-password
```

This is a limitation of the current `sshWrapper` implementation, not a limitation of `sshpass` itself.

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

When using `-p` or `-f`, passwords are stored in an unencrypted plain-text file. The `-e` option instead reads the password from the `SSHPASS` environment variable.

Anyone who can read `~/.ssh/sshpass` can obtain passwords stored using `-p` or `-f`. The `SSHPASS` environment variable may also be accessible to processes or users depending on the environment in which it is set.

For this reason, **using SSH public key authentication is strongly recommended whenever possible**.

`sshWrapper` is intended for situations where password authentication is required or otherwise preferred.
