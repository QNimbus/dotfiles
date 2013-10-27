## Synopsis

The dotfiles script automates several tasks. Downloading of frequently used tools, updating shell configuration scripts (e.g. .bashrc, .profile, et cetera) and much more

## Motivation

Everytime I have a fresh linux installation (e.g. Ubuntu) I find that I spend quite a few hours trying to tweak and reconfigure the system to my own needs. With the 'dotfiles' scripts I try to automate the most of these tasks.

## Installation

### Ubuntu Notes

* You need to be an administrator (for `sudo`).
* You need to have 'curl' installed (`apt-get install curl`)

### Actual Installation

```sh
bash -c "$(curl -fsSL https://bit.ly/qn-dotfiles)" && source ~/.bashrc
```

If, for some reason, [bit.ly](https://bit.ly/) is down, you can use the canonical URL.

```sh
bash -c "$(curl -fsSL https://raw.github.com/qnimbus/dotfiles/master/bin/install.sh)" && source ~/.bashrc
```

## Post-installation tasks

Keep in mind that some config files need to be configured to your personal settings. For example the `.gitconfig` file in the users homedir needs to have a username and an e-mail address added to it.

## Contributors

If you would like to contribute to this project in any way, feel free to drop a note. I will send you an invite.

## License

The MIT License is a permissive license that is short and to the point. It lets people do anything they want with my code as long as they provide attribution back to me and don’t hold me liable.
