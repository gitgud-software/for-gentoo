# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
EGO_PN="github.com/docker/${PN}"

if [[ ${PV} == *9999 ]]; then
	inherit golang-vcs
else
	MY_PV="${PV/_/-}"
	EGIT_COMMIT="v${MY_PV}"
	SRC_URI="https://${EGO_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~ppc64 ~arm"
	inherit golang-vcs-snapshot
fi

DESCRIPTION="A daemon to control runC"
HOMEPAGE="https://containerd.tools"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+seccomp"

DEPEND=""
RDEPEND=">=app-emulation/runc-1.0.0_rc1
	seccomp? ( sys-libs/libseccomp )"

S=${WORKDIR}/${P}/src/${EGO_PN}

src_compile() {
	local options=( $(usex seccomp "seccomp") )
	export GOPATH="${WORKDIR}/${P}" # ${PWD}/vendor
	LDFLAGS= emake GIT_COMMIT="$EGIT_COMMIT" BUILDTAGS="${options[@]}"
}

src_install() {
	dobin bin/containerd* bin/ctr
}
