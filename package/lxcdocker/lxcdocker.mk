################################################################################
#
# lxcdocker
#
################################################################################

LXCDOCKER_VERSION = 1.10.0
LXCDOCKER_SOURCE = docker-v$(LXCDOCKER_VERSION).tar.gz
LXCDOCKER_SITE = $(call github,docker,docker,v$(LXCDOCKER_VERSION))
LXCDOCKER_DEPENDENCIES = linux-headers sqlite host-go
LXCDOCKER_LICENSE = Apache
LXCDOCKER_LICENSE_FILES = LICENSE
LXCDOCKER_BUILD_TAGS = exclude_graphdriver_btrfs exclude_graphdriver_btrfs exclude_graphdriver_aufs

ifeq ($(BR2_PACKAGE_LXCDOCKER_DAEMON),y)
LXCDOCKER_BUILD_TAGS += daemon
endif

ifeq ($(BR2_PACKAGE_LXCDOCKER_EXPERIMENTAL),y)
LXCDOCKER_BUILD_TAGS += experimental
endif

ifeq ($(BR2_PACKAGE_LXCDOCKER_DRIVER_BTRFS),y)
LXCDOCKER_DEPENDENCIES += btrfs-progs
else
LXCDOCKER_BUILD_TAGS += exclude_graphdriver_btrfs
endif

ifeq ($(BR2_PACKAGE_LXCDOCKER_DRIVER_AUFS),y)
LXCDOCKER_DEPENDENCIES += aufs-util
else
LXCDOCKER_BUILD_TAGS += exclude_graphdriver_aufs
endif

ifeq ($(BR2_PACKAGE_LXCDOCKER_DRIVER_DEVICEMAPPER),y)
LXCDOCKER_DEPENDENCIES += lvm2
else
LXCDOCKER_BUILD_TAGS += exclude_graphdriver_devicemapper
endif

ifeq ($(BR2_PACKAGE_LXCDOCKER_DRIVER_VFS),y)
LXCDOCKER_DEPENDENCIES += gvfs
else
LXCDOCKER_BUILD_TAGS += exclude_graphdriver_vfs
endif


ifeq ($(BR2_arm),y)
	GO_GOARCH = arm
else ifeq ($(BR2_aarch64),y)
	GO_GOARCH = arm64
else ifeq ($(BR2_i386),y)
	GO_GOARCH = 386
else ifeq ($(BR2_x86_64),y)
	GO_GOARCH = amd64
else ifeq ($(BR2_powerpc),y)
	GO_GOARCH = ppc64
else
	GO_GOARCH = unknown
endif

ifeq ($(BR2_arm)$(BR2_ARM_CPU_ARMV5),yy)
GO_GOARM = 5
else ifeq ($(BR2_arm)$(BR2_ARM_CPU_ARMV6),yy)
GO_GOARM = 6
else ifeq ($(BR2_arm)$(BR2_ARM_CPU_ARMV7A),yy)
GO_GOARM = 7
else ifeq ($(BR2_arm),y)
GO_GOARM = unknown
endif

define LXCDOCKER_CONFIGURE_CMDS
	export GITCOMMIT=$(LXCDOCKER_VERSION) && \
	export VERSION=$(LXCDOCKER_VERSION_ID) && \
	export GOPATH=$(TARGET_DIR)/usr/src/go/ && \
	export GOOS=linux; \
	export GOARCH=$(GO_GOARCH); \
	export GOARM=$(GO_GOARM); \
	export CC="$(TARGET_CC)"; \
	export LD="$(TARGET_LD)"; \
	export CGO_ENABLED=1; \
	export CGO_NO_EMULATION=1; \
	export CC_FOR_TARGET="${TARGET_CC} ${TARGET_CC_ARCH} --sysroot=${STAGING_DIR_TARGET}"; \
	export CXX_FOR_TARGET="${TARGET_CXX} ${TARGET_CC_ARCH} --sysroot=${STAGING_DIR_TARGET}"; \
	export GO_CCFLAGS="-I$(STAGING_DIR)/usr/include/ -I$(TARGET_DIR)/usr/include -I$(LINUX_HEADERS_DIR)/fs/"; \
	export GO_LDFLAGS="-X main.GITCOMMIT $(LXCDOCKER_VERSION) -X main.VERSION $(LXCDOCKER_VERSION_ID) -w -linkmode external -extldflags '-Wl,--unresolved-symbols=ignore-in-shared-libs' -extld '$(TARGET_CC_NOCCACHE)'"; \
	export PATH="$(HOST_DIR)/usr/lib/go/bin/:$(PATH)"; \
	echo "clone git github.com/golang/protobuf ab974be44dc3b7b8a1fb306fb32fe9b9f3864b3d" >> $(@D)/hack/vendor.sh && \
	cd $(@D) && ./hack/vendor.sh
	ln -fs $(@D) $(@D)/vendor/src/github.com/docker/docker
endef

define LXCDOCKER_BUILD_CMDS
	# export CC="${BUILD_CC}"
	#export CC_FOR_TARGET="${TARGET_CC}" \
	#export CXX_FOR_TARGET="${TARGET_CXX}"
	#bash ./hack/make/.go-autogen;
	export GOPATH="$(@D)/.gopath:$(@D)/vendor"; \
	export GOOS=linux; \
	export GOARCH=$(GO_GOARCH); \
	export GOARM=$(GO_GOARM); \
	export CC="$(TARGET_CC)"; \
	export LD="$(TARGET_LD)"; \
	export CGO_ENABLED=1; \
	export CGO_NO_EMULATION=1; \
	export CC_FOR_TARGET="${TARGET_CC} ${TARGET_CC_ARCH} --sysroot=${STAGING_DIR_TARGET}"; \
	export CXX_FOR_TARGET="${TARGET_CXX} ${TARGET_CC_ARCH} --sysroot=${STAGING_DIR_TARGET}"; \
	export GO_CCFLAGS="-I$(STAGING_DIR)/usr/include/ -I$(TARGET_DIR)/usr/include -I$(LINUX_HEADERS_DIR)/fs/"; \
	export GO_LDFLAGS="-X main.GITCOMMIT $(LXCDOCKER_VERSION) -X main.VERSION $(LXCDOCKER_VERSION_ID) -w -linkmode external -extldflags '-Wl,--unresolved-symbols=ignore-in-shared-libs' -extld '$(TARGET_CC_NOCCACHE)'"; \
	export PATH="$(HOST_DIR)/usr/lib/go/bin/:$(PATH)"; \
	cd $(@D); \
	mkdir -p "$(@D)/bin"; \
	ls; \
	DOCKER_BUILDTAGS="$(LXCDOCKER_BUILD_TAGS)" bash ./hack/make.sh dynbinary;
	# $(HOST_DIR)/usr/bin/go build -v -o "$(@D)/bin/docker" -a -tags "$(LXCDOCKER_BUILD_TAGS)" -ldflags "$$GO_LDFLAGS" ./docker
endef

define LXCDOCKER_INSTALL_TARGET_CMDS
	cp -L $(@D)/bundles/$(LXCDOCKER_VERSION)/dynbinary/docker $(TARGET_DIR)/usr/bin/docker
	cp -L $(@D)/bundles/$(LXCDOCKER_VERSION)/dynbinary/dockerinit $(TARGET_DIR)/usr/bin/dockerinit
endef

define LXCDOCKER_USERS
	- - docker -1 * - - - Docker Application Container Framework
endef

$(eval $(generic-package))
