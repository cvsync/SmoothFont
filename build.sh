#! /bin/sh

VER_MAJOR=1
VER_MINOR=0
VER_REV=1

MAX_PACK_FORMAT=84
MAX_PACK_FORMAT_MINOR=0

MIN_PACK_FORMAT=69
MIN_PACK_FORMAT_MINOR=0

RESOURCE_PACK_NAME=SmoothFont

TMPDIR=./tmp
FONT_DSTDIR=${TMPDIR}/assets/minecraft/font

font_pack() {
	FONTNAME="$1"
	FONTFILE_URL="$2"
	FONTFILE=$(echo ${FONTFILE_URL##*/} | tr [A-Z] [a-z] | sed 's/-//g')

	RESOURCE_PACK_FILE_JAVA="${RESOURCE_PACK_NAME}-${FONTNAME}".zip

	#
	# init
	#
	sudo rm -f -r ${TMPDIR}
	mkdir -p ${TMPDIR} ${TMPDIR}/assets ${TMPDIR}/assets/minecraft
	mkdir -p ${TMPDIR}/assets/minecraft/font ${TMPDIR}/assets/minecraft/font/fonts

	# Download font file
	curl -L ${FONTFILE_URL} -o ${FONT_DSTDIR}/fonts/${FONTFILE}

	#
	# pack.mcdata
	#
	_file=pack.mcmeta
	cat "${RESOURCE_PACK_NAME}/${_file}.${FONTNAME}" | \
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
		sed "s/XXXFONTFILEXXX/${FONTFILE}/g" | \
		sed "s///g" > ${FONT_DSTDIR}/${_file}
	done

	#
	# change owner / group
	#
	(cd ${TMPDIR}/ && sudo chown -R 0:0 .)

	#
	# zip-fy
	#
	(cd ${TMPDIR}/ && zip -r ../${RESOURCE_PACK_FILE_JAVA} . -i "*")

	#
	# Clean up
	#
	sudo rm -f -r ${TMPDIR}
}

#
# for Java Edition
#
sudo rm -f *.zip
font_pack bizud https://github.com/googlefonts/morisawa-biz-ud-gothic/raw/refs/heads/main/fonts/ttf/BIZUDPGothic-Regular.ttf
font_pack mplus https://github.com/coz-m/MPLUS_FONTS/raw/refs/heads/master/fonts/ttf/Mplus1-Medium.ttf
font_pack plexsans https://github.com/IBM/plex/raw/refs/heads/master/packages/plex-sans-jp/fonts/complete/ttf/hinted/IBMPlexSansJP-Medium.ttf

mkdir -p ${VER_MAJOR}.${VER_MINOR}.${VER_REV}
cp ./*.zip ${VER_MAJOR}.${VER_MINOR}.${VER_REV}/
ls -l ${VER_MAJOR}.${VER_MINOR}.${VER_REV}/
