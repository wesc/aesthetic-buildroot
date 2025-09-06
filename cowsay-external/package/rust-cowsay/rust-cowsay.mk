################################################################################
#
# rust-cowsay
#
################################################################################

RUST_COWSAY_VERSION = 4c85805169b87976d42b081966bafcc6a779e3a9
RUST_COWSAY_SITE = $(call github,wesc,rust-cowsay,$(RUST_COWSAY_VERSION))
RUST_COWSAY_LICENSE = MIT
RUST_COWSAY_LICENSE_FILES = LICENSE
RUST_COWSAY_DEPENDENCIES = host-rustc

$(eval $(cargo-package))
