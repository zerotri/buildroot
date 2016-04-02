################################################################################
#
# go-bootstrap
#
################################################################################

GO_BOOTSTRAP_VERSION = 1.4.2
GO_BOOTSTRAP_SITE = https://storage.googleapis.com/golang
GO_BOOTSTRAP_SOURCE = go$(GO_BOOTSTRAP_VERSION).src.tar.gz

GO_BOOTSTRAP_LICENSE = BSD-3c
GO_BOOTSTRAP_LICENSE_FILES = LICENSE

GO_BOOTSTRAP_FINAL = $(HOST_DIR)/usr/lib/go-$(GO_BOOTSTRAP_VERSION)

GO_BOOTSTRAP_MAKE_ENV = \
	GOOS=linux \
	GOROOT_FINAL="$(GO_BOOTSTRAP_FINAL)" \
	GOROOT="$(@D)" \
	GOBIN="$(@D)/bin"

define HOST_GO_BOOTSTRAP_BUILD_CMDS
	cd $(@D)/src && $(GO_BOOTSTRAP_MAKE_ENV) ./make.bash
endef

define HOST_GO_BOOTSTRAP_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/go $(GO_BOOTSTRAP_FINAL)/bin/go
	$(INSTALL) -D -m 0755 $(@D)/bin/gofmt $(GO_BOOTSTRAP_FINAL)/bin/gofmt

	cp -a $(@D)/lib $(GO_BOOTSTRAP_FINAL)/
	cp -a $(@D)/pkg $(GO_BOOTSTRAP_FINAL)/

	# There is a known issue which requires the go sources to be installed
	# https://golang.org/issue/2775
	cp -a $(@D)/src $(GO_BOOTSTRAP_FINAL)/
endef

$(eval $(host-generic-package))
