#!/bin/bash

IMAGE_DIR=$1

BOARD_DIR="${IMAGE_DIR}/../../board/nextthing/chipswarm"
HOST_DIR="${IMAGE_DIR}/../host"
BOOTFS_DIR="${IMAGE_DIR}/bootfs"


mkdir "${BOOTFS_DIR}"

cp "${IMAGE_DIR}/zImage" "${BOOTFS_DIR}"
cp "${IMAGE_DIR}/sun5i-r8-chip.dtb" "${BOOTFS_DIR}"
cp "${IMAGE_DIR}/rootfs.cpio.uboot" "${BOOTFS_DIR}"

${HOST_DIR}/usr/sbin/mkfs.ubifs -d ${BOOTFS_DIR} \
	-e 0x1f8000 -m 0x4000 -c 800 \
	-o "${IMAGE_DIR}/bootfs.ubifs" 
	

install -m 0644 "${BOARD_DIR}/ubinize.cfg" "${IMAGE_DIR}/ubinize.cfg"

sed -i "s;BOOTFS_UBIFS;${IMAGE_DIR}/bootfs.ubifs;" "${IMAGE_DIR}/ubinize.cfg"

${HOST_DIR}/usr/sbin/ubinize -o "${IMAGE_DIR}/bootfs.ubi" \
	-m 0x4000 -p 0x200000 -s 16384 \
	"${IMAGE_DIR}/ubinize.cfg"

img2simg ${IMAGE_DIR}/bootfs.ubi ${IMAGE_DIR}/bootfs.sparse.ubi $((2*1024*1024))
img2simg ${IMAGE_DIR}/rootfs.ubi ${IMAGE_DIR}/rootfs.sparse.ubi $((2*1024*1024))