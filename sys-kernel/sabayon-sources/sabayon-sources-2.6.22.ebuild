# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_WANT_GENPATCHES=""
K_GENPATCHES_VER=""
inherit kernel-2
detect_version
detect_arch


#amd64? ( http://www.sabayonlinux.org/sabayon/kconfigs/SabayonLinux-x86-64-3.3.1.config )
#x86? ( http://www.sabayonlinux.org/sabayon/kconfigs/SabayonLinux-x86-3.3.1.config )


SL_PATCHES_URI="
		http://www.kernel.org/pub/linux/kernel/v2.6/patch-2.6.22.1.bz2
		"

SUSPEND2_VERSION="2.2.10"
SUSPEND2_TARGET="2.6.22"
SUSPEND2_SRC="suspend2-${SUSPEND2_VERSION}-for-${SUSPEND2_TARGET}"
SUSPEND2_URI="http://www.tuxonice.net/downloads/all/${SUSPEND2_SRC}.patch.bz2"

UNIPATCH_LIST="
		${FILESDIR}/${P}-wireless-dev.patch
		${FILESDIR}/${P}-rt2x00-updates.patch

		${FILESDIR}/${P}-fbsplash-0.9.2-r5.patch ${FILESDIR}/${P}-linux-phc-0.2.10.patch
		${FILESDIR}/${P}-squashfs-3.2.patch ${DISTDIR}/${SUSPEND2_SRC}.patch.bz2
		${FILESDIR}/${P}-ipw3945-1.2.0-2.6.22.patch ${FILESDIR}/${P}-unionfs-1.3.diff
		${FILESDIR}/${PN}-2.6.21-from-ext4dev-to-ext4.patch ${FILESDIR}/${P}-cfs-19.patch
		${FILESDIR}/${P}-thinkpad.patch ${FILESDIR}/${P}-toshiba.patch
		${FILESDIR}/${P}-dvb-af9005.patch

		${FILESDIR}/${P}-mactel-appleir.patch
		${FILESDIR}/${P}-mactel-applesmc.patch
		${FILESDIR}/${P}-mactel-sigmatel-audio.patch

		${FILESDIR}/${P}-pm-appletouch.patch
		${FILESDIR}/${P}-pm-hdaps.patch
		${FILESDIR}/${P}-pm-hpet-intel.patch
		${FILESDIR}/${P}-pm-jiffies-patches.patch

		${FILESDIR}/${P}-at76c503a.patch
		${FILESDIR}/${P}-acx.patch

		${FILESDIR}/${P}-ich8m-support.patch

		${DISTDIR}/patch-2.6.22.1.bz2

		"
# disabled for testing
# ${FILESDIR}/${PN}-2.6.21-tiacx-drivers.patch


UNIPATCH_STRICTORDER="yes"

KEYWORDS="~amd64 ~x86 ~ppc ~ppc64"
HOMEPAGE="http://dev.gentoo.org/~dsd/genpatches http://www.sabayonlinux.org"

DESCRIPTION="Full sources including the Gentoo patchset and SabayonLinux ones for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI} ${SUSPEND2_URI} ${SL_PATCHES_URI}"

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "This is a modified version of the Gentoo's gentoo-sources. Please report problems to us first."
	einfo "http://bugs.sabayonlinux.org"
}

src_compile() {
	if use build; then

		# setup sandbox permissions
		addwrite /etc/kernels
		addwrite /var/tmp/genkernel
		addwrite /usr/share/genkernel
		addwrite /dev

		# creating workdirs
		mkdir ${WORKDIR}/boot/grub/
		mkdir ${WORKDIR}/lib
		mkdir ${WORKDIR}/cache
		if [ -e "/boot/grub/grub.conf" ]; then
			cp /boot/grub/grub.conf ${WORKDIR}/boot/grub/ -p
		fi

		cd ${S}
		if use amd64; then
			KCONF="${DISTDIR}"/SabayonLinux-x86-64-3.3.config
		elif use x86; then
			KCONF="${DISTDIR}"/SabayonLinux-x86-3.3.config
		fi
		# spawn genkernel

		GKARGS="--dmraid --lvm2 --luks --gensplash=sabayon"
		#if use dmraid; then
		#	GKARGS="${GKARGS} --dmraid"
		#fi
		#if use lvm2; then
		#	GKARGS="${GKARGS} --lvm2"
		#fi
		#if use luks; then
		#	GKARGS="${GKARGS} --luks"
		#fi
		#if use sabayon_splash; then
		#	GKARGS="${GKARGS} --gensplash=sabayon"
		#fi

		OLDARCH=${ARCH}
		unset ARCH
		genkernel ${GKARGS} \
			--kerneldir=${S} \
			--kernel-config=${KCONF} \
			--cachedir=${WORKDIR}/cache \
			--makeopts=-j2 \
			--debugfile=${WORKDIR}/genkernel.log \
			--bootdir=${WORKDIR}/boot \
			--module-prefix=${WORKDIR}/lib \
			--bootloader=grub \
			all || die "genkernel failed"
		ARCH=${OLDARCH}
	fi
}


src_install() {
	kernel-2_src_install || die "kernel-2_src_install failed"
	
	if use build; then
		# installing the kernel
		cd ${WORKDIR}/boot
		insinto /boot
		doins -r ./*

		# installing the modules
		cd ${WORKDIR}/lib/lib
		insinto /lib
		doins -r ./*

		# installing new grub.conf
		if [ -e "${WORKDIR}/boot/grub.conf" ]; then
			insinto /boot/grub/
			doins ${WORKDIR}/boot/grub.conf
		fi
	fi
}
