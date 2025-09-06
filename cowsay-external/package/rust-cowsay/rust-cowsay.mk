################################################################################
#
# rust-cowsay
#
################################################################################

RUST_COWSAY_VERSION = 4b49e8118de14dd173185ae078c6b93fbceea749
RUST_COWSAY_SITE = $(call github,wesc,rust-cowsay,$(RUST_COWSAY_VERSION))
RUST_COWSAY_LICENSE = MIT
RUST_COWSAY_LICENSE_FILES = LICENSE
RUST_COWSAY_DEPENDENCIES = host-rustc

$(eval $(cargo-package))
