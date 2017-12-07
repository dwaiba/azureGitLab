#!/bin/bash
#should work for all skus
set -x
#set -xeuo pipefail

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi

if [ $# != 3 ]; then
    echo "Usage: $0 <dockerVer> <dockerComposeVer> <dockerMachineVer>"
    exit 1
fi


dockerVer=$( echo "$1" )
dockerComposeVer=$( echo "$2" )
dockMVer=$( echo "$3" )



set_time()
{
    mv /etc/localtime /etc/localtime.bak
    #ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
    /usr/share/zoneinfo/US/Central /etc/localtime
}


# System Update.
#
system_update()
{
    rpm --rebuilddb
    updatedb
    yum clean all
    yum -y install epel-release
    #yum  -y update --exclude=WALinuxAgent
    #yum  -y update
    #yum -x 'intel-*' -x 'kernel*' -x '*microsoft-*' -x 'msft-*'  -y update --exclude=WALinuxAgent
    yum --exclude WALinuxAgent,intel-*,kernel*,kernel-headers*,*microsoft-*,msft-* -y update 

    set_time
}

install_docker_ubuntu()
{
	
        # System Update and docker version update
	DEBIAN_FRONTEND=noninteractive apt-mark hold walinuxagent
        DEBIAN_FRONTEND=noninteractive apt-get -y update
         apt-get install -y apt-transport-https ca-certificates curl
	 DEBIAN_FRONTEND=noninteractive apt-get -y update
         DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
	 apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
         curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
       add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
       DEBIAN_FRONTEND=noninteractive apt-get -y update
	 groupadd docker
	 usermod -aG docker $userName
	 apt-get -y install $dockerVer
	 /etc/init.d/apparmor stop 
	 /etc/init.d/apparmor teardown 
	 update-rc.d -f apparmor remove
	 apt-get -y remove apparmor
    curl -L https://github.com/docker/compose/releases/download/$dockerComposeVer/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    curl -L https://github.com/docker/machine/releases/download/v$dockMVer/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine
    chmod +x /usr/local/bin/docker-machine
    chmod +x /usr/local/bin/docker-compose
    export PATH=$PATH:/usr/local/bin/
    systemctl restart docker
}


install_docker_apps()
{

    
    docker run -dti --restart=always --name=azure-cli microsoft/azure-cli
    docker run -dti --restart=always --name=azure-cli-python azuresdk/azure-cli-python
    docker run -dti --restart=always --name=vsts-cli microsoft/vsts-cli
}


install_packages_ubuntu()
{
set_time;
system_update;
DEBIAN_FRONTEND=noninteractive apt-mark hold walinuxagent
DEBIAN_FRONTEND=noninteractive apt-get install -y zlib1g zlib1g-dev  bzip2 libbz2-dev libssl1.0.0  libssl-doc libssl1.0.0-dbg libsslcommon2 libsslcommon2-dev libssl-dev  nfs-common rpcbind git zip libicu55 libicu-dev icu-devtools unzip mdadm wget gsl-bin libgsl2  bc ruby-dev gcc make autoconf bison build-essential libyaml-dev libreadline6-dev libncurses5 libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libpam0g-dev libxtst6 libxtst6-* libxtst-* libxext6 libxext6-* libxext-* git-core libelf-dev asciidoc binutils-dev fakeroot crash kexec-tools makedumpfile kernel-wedge portmap
DEBIAN_FRONTEND=noninteractive apt-get -y build-dep linux
DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

DEBIAN_FRONTEND=noninteractive update-initramfs -u
}

#########################
	if [ "$skuName" == "16.04-LTS" ] ; then
		install_packages_ubuntu
                install_docker_ubuntu
		install_docker_apps
        fi
