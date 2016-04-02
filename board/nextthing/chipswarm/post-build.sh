#!/bin/bash

TARGET_DIR=$1

cat <<EOF >${TARGET_DIR}/etc/issue
Welcome to CHIP Swarm
EOF
