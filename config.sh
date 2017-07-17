#!/bin/bash

BASE_URL="http://distfiles.gentoo.org/releases/amd64/autobuilds/"

#IMG="gentoo.img"
#ISO="install-amd64-minimal-20150430.iso"
#STAGE=stage3-amd64-20150507.tar.bz2
#PORTAGE=portage-20150511.tar.bz2
#QEMU_MEMORY="512"
#QEMU_NET_TYPE="user"
#KERNEL_CONFIGURE="0"
#KERNEL_MAKE_OPTS=""
#EMERGE_EXTRA_PACKAGES

EMERGE_BASE_PACKAGES="acpid dmidecode syslog-ng cronie dhcpcd mlocate xfsprogs dosfstools grub sudo postfix cloud-init vim gentoo-sources linux-firmware parted portage-utils gentoolkit bash-completion gentoo-bashcomp eix tmux app-misc/screen dev-vcs/git net-misc/curl usbutils pciutils logrotate gptfdisk sys-block/gpart openssh"


if [ -z "${ISO}" -o ! -f "iso/${ISO}" ];then
    OUTPUT=$(curl "${BASE_URL}latest-install-amd64-minimal.txt" 2> /dev/null)
    CURRENT=$(echo "${OUTPUT}" | sed -e 's/#.*$//' -e '/^$/d' | cut -d ' ' -f1)
    ISO=$(echo "${CURRENT}" | cut -d '/' -f2)

    if [ -f "iso/${ISO}" ];then
        :
        echo "latest iso ${ISO} already downloaded"
    else
        :
        echo "downloading current iso ${ISO}"
        curl -o "iso/${ISO}" "${BASE_URL}${CURRENT}";
    fi
fi


if [ -z "${STAGE}" -o ! -f "builder/${STAGE}" ];then
    OUTPUT=$(curl "${BASE_URL}latest-stage3-amd64.txt" 2> /dev/null)
    CURRENT=$(echo "${OUTPUT}" | sed -e 's/#.*$//' -e '/^$/d' | cut -d ' ' -f1)
    STAGE=$(echo "${CURRENT}" | cut -d '/' -f2)

    if [ -f "builder/${STAGE}" ];then
        :
        echo "latest stage ${STAGE} already downloaded"
    else
        :
        echo "downloading current stage ${STAGE}"
        curl -o "builder/${STAGE}" "${BASE_URL}${CURRENT}";
    fi
fi


if [ -z "${PORTAGE}" ];then
    PORTAGE="portage-$(date --date yesterday +%Y%m%d).tar.bz2"

    if [ -f "builder/${PORTAGE}" ];then
        :
        echo "latest portage ${PORTAGE} already downloaded"
    else
        :
        echo "downloading current portage ${PORTAGE}"
        curl -o "builder/${PORTAGE}" "http://distfiles.gentoo.org/releases/snapshots/current/${PORTAGE}";
    fi
fi


if [ -z "${IMG}" ];then
    IMG="gentoo.img"
fi

if [ ! -f "${IMG}" ];then
    echo "creating ${IMG} image file"
    qemu-img create -f qcow2 "${IMG}" 10G
fi

rm builder/builder.cfg 2> /dev/null
echo "# autogenerated by config.sh" >> builder/builder.cfg
echo "PORTAGE=\"${PORTAGE}\"" >> builder/builder.cfg
echo "STAGE=\"${STAGE}\"" >> builder/builder.cfg
echo "DEV=\"/dev/vda\"" >> builder/builder.cfg
echo "PART=\"/dev/vda3\"" >> builder/builder.cfg
echo "BOOT_PART=\"/dev/vda2\"" >> builder/builder.cfg
echo "KERNEL_CONFIGURE=\"${KERNEL_CONFIGURE}\"" >> builder/builder.cfg
echo "KERNEL_MAKE_OPTS=\"${KERNEL_MAKE_OPTS}\"" >> builder/builder.cfg
echo "EMERGE_BASE_PACKAGES=\"${EMERGE_BASE_PACKAGES}\"" >> builder/builder.cfg
echo "EMERGE_EXTRA_PACKAGES=\"${EMERGE_EXTRA_PACKAGES}\"" >> builder/builder.cfg
