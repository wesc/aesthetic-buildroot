################################################################################
#
# rust-bindgen70
#
################################################################################

RUST_BINDGEN70_VERSION = 0.70.1
RUST_BINDGEN70_SITE = $(call github,rust-lang,rust-bindgen,v$(RUST_BINDGEN70_VERSION))
RUST_BINDGEN70_SOURCE = rust-bindgen-$(RUST_BINDGEN70_VERSION).tar.gz
RUST_BINDGEN70_LICENSE = BSD-3-clause
RUST_BINDGEN70_LICENSE_FILES = LICENSE
RUST_BINDGEN70_DEPENDENCIES = llvm host-clang

# The Cargo.toml at the root directory is a "virtual manifest".
# Since we only want to build and install bindgen use the Cargo.toml
# from the bindgen-cli subdirectory.
RUST_BINDGEN70_SUBDIR = bindgen-cli

$(eval $(host-cargo-package))
