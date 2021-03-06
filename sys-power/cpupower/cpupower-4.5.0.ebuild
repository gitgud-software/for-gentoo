# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit multilib toolchain-funcs systemd

DESCRIPTION="Shows and sets processor power related values"
HOMEPAGE="https://www.kernel.org/"
SRC_URI="https://dev.gentoo.org/~floppym/dist/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="cpufreq_bench debug nls +systemd"

# File collision w/ headers of the deprecated cpufrequtils
RDEPEND="sys-apps/pciutils
	!<sys-apps/linux-misc-apps-3.6-r2
	!sys-power/cpufrequtils"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	virtual/os-headers
	nls? ( sys-devel/gettext )"

src_compile() {
	myemakeargs=(
		DEBUG=$(usex debug true false)
		V=1
		CPUFREQ_BENCH=$(usex cpufreq_bench true false)
		NLS=$(usex nls true false)
		docdir=/usr/share/doc/${PF}/${PN}
		mandir=/usr/share/man
		libdir=/usr/$(get_libdir)
		AR="$(tc-getAR)"
		CC="$(tc-getCC)"
		LD="$(tc-getCC)"
		STRIP=true
		OPTIMIZATION=
		VERSION=${PV}
	)

	emake "${myemakeargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" "${myemakeargs[@]}" install
	dodoc README ToDo

	newconfd "${FILESDIR}"/conf.d-r2 cpupower
	newinitd "${FILESDIR}"/init.d-r4 cpupower

	# Adding default cpupower configuration
	insinto /etc/sysconfig
	doins "${FILESDIR}"/cpupower

	if use systemd; then
		systemd_newunit "${FILESDIR}"/cpupower.service cpupower.service
	fi
}
