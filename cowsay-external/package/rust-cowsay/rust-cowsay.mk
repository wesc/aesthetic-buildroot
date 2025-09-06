################################################################################
#
# rust-cowsay
#
################################################################################

RUST_COWSAY_VERSION = master
RUST_COWSAY_SITE = https://github.com/wesc/rust-cowsay
RUST_COWSAY_SITE_METHOD = git
RUST_COWSAY_LICENSE = MIT
RUST_COWSAY_LICENSE_FILES = LICENSE

RUST_COWSAY_DEPENDENCIES = host-rustc

define RUST_COWSAY_BUILD_CMDS
	cd $(@D) && \
	$(HOST_DIR)/bin/cargo build --release --target-dir $(RUST_COWSAY_BUILDDIR)
endef

define RUST_COWSAY_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(RUST_COWSAY_BUILDDIR)/release/cowsay \
		$(TARGET_DIR)/usr/bin/cowsay
endef

$(eval $(generic-package))
