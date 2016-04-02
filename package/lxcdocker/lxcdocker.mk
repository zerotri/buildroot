################################################################################
#
# lxcdocker
#
################################################################################

LXCDOCKER_VERSION = 1.7.1
LXCDOCKER_SITE = $(call github,docker,docker,v$(LXCDOCKER_VERSION))
LXCDOCKER_DEPENDENCIES = linux-headers sqlite host-go
LXCDOCKER_LICENSE = Apache
LXCDOCKER_LICENSE_FILES = LICENSE
LXCDOCKER_BUILD_TAGS = exclude_graphdriver_btrfs

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

define LXCDOCKER_CONFIGURE_CMDS
	export GITCOMMIT=$(LXCDOCKER_VERSION) && \
	export VERSION=$(LXCDOCKER_VERSION_ID) && \
	export GOPATH=$(TARGET_DIR)/usr/src/go/ && \
	echo "clone git github.com/golang/protobuf ab974be44dc3b7b8a1fb306fb32fe9b9f3864b3d" >> $(@D)/hack/vendor.sh && \
	cd $(@D) && ./hack/vendor.sh
	ln -fs $(@D) $(@D)/vendor/src/github.com/docker/docker
endef

define LXCDOCKER_BUILD_CMDS
	export GOPATH="$(@D)/.gopath:$(@D)/vendor"; \
	export GOOS=linux; \
	export GOARCH=$(ARCH); \
	export CGO_ENABLED=1; \
	export CGO_NO_EMULATION=1; \
	export CGO_CFLAGS='-I$(STAGING_DIR)/usr/include/ -I$(TARGET_DIR)/usr/include -I$(LINUX_HEADERS_DIR)/fs/'; \
	export LDFLAGS="-X main.GITCOMMIT $(LXCDOCKER_VERSION) -X main.VERSION $(LXCDOCKER_VERSION_ID) -w -linkmode external -extldflags '-Wl,--unresolved-symbols=ignore-in-shared-libs' -extld '$(TARGET_CC_NOCCACHE)'"; \
	export CC="$(TARGET_CC_NOCCACHE)"; \
	export LD="$(TARGET_LD)"; \
	cd $(@D); \
 	mkdir -p bin; \
	bash ./hack/make/.go-autogen; \
	$(HOST_DIR)/usr/bin/go build -v -o "$(@D)/bin/docker" -a -tags "$(LXCDOCKER_BUILD_TAGS)" -ldflags "$$LDFLAGS" ./docker
endef

define LXCDOCKER_INSTALL_TARGET_CMDS
	cp -L $(@D)/bin/docker $(TARGET_DIR)/usr/bin/docker
endef

define LXCDOCKER_USERS
	- - docker -1 * - - - Docker Application Container Framework
endef

$(eval $(generic-package))
