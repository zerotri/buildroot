#!/bin/bash

TARGET_DIR=$1

cat <<EOF >${TARGET_DIR}/etc/issue
Welcome to CHIP Swarm
EOF

if [ ! -d "${TARGET_DIR}/cgroups" ]; then
	mkdir "${TARGET_DIR}/cgroups"
fi

cat "${TARGET_DIR}/../images/zImage" "${TARGET_DIR}/../images/sun5i-r8-chip.dtb" > "${TARGET_DIR}/../images/zImage_with_dtb"

rm -rf "${TARGET_DIR}/etc/X11"
