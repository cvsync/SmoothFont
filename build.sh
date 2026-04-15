#! /bin/sh

VER_MAJOR=1
VER_MINOR=1
VER_REV=0

MAX_PACK_FORMAT=84
MAX_PACK_FORMAT_MINOR=0

MIN_PACK_FORMAT=69
MIN_PACK_FORMAT_MINOR=0

RESOURCE_PACK_NAME=SmoothFont

TMPDIR=./tmp
FONT_DSTDIR=${TMPDIR}/assets/minecraft/font

font_pack() {
	FONT_NAME="$1"
	FONT_URL="$2"
	FONT_LICENSE_URL="$3"

	FONT_FILE=$(echo ${FONT_URL##*/} | tr [A-Z] [a-z])
	FONT_LICENSE_FILE=${FONT_LICENSE_URL##*/}

	RESOURCE_PACK_FILE_JAVA="${RESOURCE_PACK_NAME}-${FONT_NAME}".zip

	#
	# init
	#
	sudo rm -f -r ${TMPDIR}
	mkdir -p ${TMPDIR} ${TMPDIR}/assets ${TMPDIR}/assets/minecraft
	mkdir -p ${TMPDIR}/assets/minecraft/font ${TMPDIR}/assets/minecraft/font/fonts

	# Download font file and license
	curl -L ${FONT_URL} -o ${FONT_DSTDIR}/fonts/${FONT_FILE}
	curl -L ${FONT_LICENSE_URL} -o ${FONT_DSTDIR}/fonts/${FONT_LICENSE_FILE}

	#
	# pack.mcdata
	#
	_file=pack.mcmeta
	cat "${RESOURCE_PACK_NAME}/${_file}.${FONT_NAME}" | \
	sed "s/XXXMAXPACKFORMATXXX/${MAX_PACK_FORMAT}/g" | \
	sed "s/XXXMAXPACKFORMATMINORXXX/${MAX_PACK_FORMAT_MINOR}/g" | \
	sed "s/XXXMINPACKFORMATXXX/${MIN_PACK_FORMAT}/g" | \
	sed "s/XXXMINPACKFORMATMINORXXX/${MIN_PACK_FORMAT_MINOR}/g" | \
	sed "s/XXXMAJORXXX/${VER_MAJOR}/g" | \
	sed "s/XXXMINORXXX/${VER_MINOR}/g" | \
	sed "s/XXXREVXXX/${VER_REV}/g" | \
	sed "s///g" > "${TMPDIR}/${_file}"

	#
	# default.json / uniform.json
	#
	for _file in default.json uniform.json
	do
		cat ${RESOURCE_PACK_NAME}/assets/minecraft/font/${_file} | \
		sed "s/XXXFONTFILEXXX/${FONT_FILE}/g" | \
		sed "s///g" > ${FONT_DSTDIR}/${_file}
	done

	#
	# change owner / group
	#
	(cd ${TMPDIR}/ && sudo chown -R 0:0 .)

	#
	# zip-fy
	#
	(cd ${TMPDIR}/ && zip -r ../${VER_MAJOR}.${VER_MINOR}.${VER_REV}/${RESOURCE_PACK_FILE_JAVA} . -i "*")

	#
	# Clean up
	#
	sudo rm -f -r ${TMPDIR}
}

#
# for Java Edition
#
rm -f -r ${VER_MAJOR}.${VER_MINOR}.${VER_REV}
mkdir -p ${VER_MAJOR}.${VER_MINOR}.${VER_REV}

font_pack bizud https://github.com/googlefonts/morisawa-biz-ud-gothic/raw/refs/heads/main/fonts/ttf/BIZUDPGothic-Regular.ttf https://github.com/googlefonts/morisawa-biz-ud-gothic/raw/refs/heads/main/OFL.txt
font_pack kosugi https://github.com/googlefonts/kosugi-maru/raw/refs/heads/main/fonts/ttf/KosugiMaru-Regular.ttf https://github.com/googlefonts/kosugi-maru/raw/refs/heads/main/LICENSE.txt
font_pack mplus https://github.com/coz-m/MPLUS_FONTS/raw/refs/heads/master/fonts/MPLUS1/ttf/MPLUS1-Medium.ttf https://github.com/coz-m/MPLUS_FONTS/raw/refs/heads/master/OFL.txt
font_pack plexsans https://github.com/IBM/plex/raw/refs/heads/master/packages/plex-sans-jp/fonts/complete/ttf/hinted/IBMPlexSansJP-Medium.ttf https://github.com/IBM/plex/raw/refs/heads/master/LICENSE.txt

ls -l ${VER_MAJOR}.${VER_MINOR}.${VER_REV}/
