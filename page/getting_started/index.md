# Installation

## openSUSE
<!--
    <h2>
    <a id="automatic-installation-with-yast-one-click-install" class="anchor" href="#automatic-installation-with-yast-one-click-install" aria-hidden="true">
      <span aria-hidden="true" class="octicon octicon-link"></span></a>Automatic installation with yast one-click-install</h2>

    <p>Simply search on <a id=ymp_link href="https://software.opensuse.org/package/kanku">software.opensuse.org</a> for your distribution and install the package</p>

    <h2><a id="manual-installation" class="anchor" href="#manual-installation" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>Manual installation</h2>

    <h3><a id="install-opensuse" class="anchor" href="#install-opensuse" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>openSUSE</h3>

    <pre><code>
-->


    zypper ar obs://devel:kanku devel:kanku
    zypper ar obs://devel:kanku:perl devel:kanku:perl
    zypper ref -s
    zypper in kanku-cli


## Fedora/RedHat


    curl https://download.opensuse.org/repositories/devel:/kanku/Fedora_Rawhide/devel:kanku.repo > /etc/yum.repos.d/devel:kanku.repo
    curl https://download.opensuse.org/repositories/devel:/kanku:/perl/Fedora_Rawhide/devel:kanku:perl.repo > /etc/yum.repos.d/devel:kanku:perl.repo
    dnf install kanku-cli
    usermod -a -G wheel kanku
    usermod -a -G libvirt kanku


## Ubuntu/Debian


    sudo sh -c 'echo "deb https://download.opensuse.org/repositories/devel:/kanku/xUbuntu_22.04/ ./" > /etc/apt/sources.list.d/kanku.list'
    sudo sh -c 'echo "deb https://download.opensuse.org/repositories/devel:/kanku:/perl:/deb/xUbuntu_22.04/ ./" >> /etc/apt/sources.list.d/kanku.list'
    curl https://download.opensuse.org/repositories/devel:/kanku:/perl:/deb/xUbuntu_22.04/Release.key |sudo apt-key add -
    curl https://download.opensuse.org/repositories/devel:/kanku:/staging/xUbuntu_22.04/Release.key   |sudo apt-key add -
    sudo apt update
    sudo apt install -y kanku-cli


## Setup your environment

    sudo kanku setup --devel

    # if you would like to have more control about the modifications on your system
    # please use:
    # sudo kanku setup --devel --interactive

    sudo shutdown -r now


### Preparing a new Project

The command `kanku init` will create a default Kankufile 
which should give you a good starting point.

The option `--memory=...` defines the RAM of the virtual guest and is optional.
Default is 2G of RAM.
For more options SEE `kanku init --help`


    # create directory
    mkdir MyProject

    # cd in project's directory
    cd MyProject

    kanku init --memory=2G --domain_name my-project




### Download, create and start a new guest


    kanku up


### Connect to new machine

Per default, if it exists, your ssh key is added to the authorized keys file

Otherwise you can login as

* User: kanku / Password "kankusho"
* User: root / Pasword "kankudai"

**Please change the passwords at first login**


#### Connect with user kanku

    kanku ssh

#### Connect as user root

    kanku ssh -u root