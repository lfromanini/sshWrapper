<img align="right" src="https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg">

# sshWrapper
An SSh wrapper to retrieve sshpass credentials and use it to log-in in the remote host.

```
         _  __        __                               
 ___ ___| |_\ \      / / __ __ _ _ __  _ __   ___ _ __ 
/ __/ __| '_ \ \ /\ / / '__/ _` | '_ \| '_ \ / _ \ '__|
\__ \__ \ | | \ V  V /| | | (_| | |_) | |_) |  __/ |   
|___/___/_| |_|\_/\_/ |_|  \__,_| .__/| .__/ \___|_|   
                                |_|   |_|              
```

## Usage

This wrapper works with `ssh` and `scp`!

If `ssh` is called, **sshWrapper** will search in `~/.ssh/sshpass` file the credentials to the host and use to connect to host. The command will be *transformed* from:

```bash
ssh [args] my.ssh.server [more args]
```
To:

```bash
sshpass -pPassword ssh [args] my.ssh.server [more args] -o PreferredAuthentications=password
# or, if a file containing the password is informed:
sshpass -fPath/to/PasswordFile ssh [args] my.ssh.server [more args] -o PreferredAuthentications=password
```
If no sshpass entry is found, the vanilla version of `ssh` (usually `/usr/bin/ssh`) will be used instead, without any changes.

The same logic applies to `scp`.

The `~/.ssh/sshpass` file can be configured using any placeholder accepted by `~/.ssh/config` file, i.e **?** and **\***. The examples below are valid entries in `~/.ssh/sshpass`, and the `LocalCommand` session must be similar to:

```config
Host my.ssh.server
    LocalCommand    sshpass -p thisIsThePassword

Host *.localdomain
    LocalCommand    sshpass -f path/to/fileContainingThePassword
```

**Don't** add any other option than `LocalCommand` in `~/.ssh/sshpass` because it will be **ignored** during the connection. Other options can be added to regular `~/.ssh/config` file, as usual.

#### Limitations

Because the way `ssh` deals with config options, **only one password per host is allowed** for now, which means that every user will share the same password during connection. If you want to use a user with a different password than the registred in `~/.ssh/sshpass` to connect to server, you need to escape **sshWrapper** alias with `command ssh`, otherwise, a wrong password will be used without any prompt.


## Installation

### Bash and Zsh

1. Get it:

Download the file named `sshWrapper.sh`.

```bash
curl -O https://raw.githubusercontent.com/lfromanini/sshWrapper/master/sshWrapper.sh
```

2. Include it:

Then source the file in your `~/.bashrc` and/or `~/.zshrc`:

```bash
$EDITOR ~/.bashrc
# and/or
$EDITOR ~/.zshrc
```

```diff
( ... )
+ source path/to/sshWrapper.sh
( ... )
```

Finally, reload your configurations.

```bash
source ~/.bashrc
# or
source ~/.zshrc
```
3. Done!

#### Requirements

* [sshpass](https://linux.die.net/man/1/sshpass)
* Because of the potential for abuse, the `~/.ssh/sshpass` file must have strict permissions: read/write for the user, and not accessible by others.

## Security Warning

This method requires you to store the passwords insecurely in a plain unencrypted text file. Most user should use SSh's more secure public key authentication instead.
