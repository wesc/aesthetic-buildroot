################################################################################
#
# librespot
#
################################################################################

LIBRESPOT_LICENSE = MIT
LIBRESPOT_VERSION = $(call qstrip,$(or $(BR2_PACKAGE_LIBRESPOT_VERSION),7d94e86ebcd9d42a7f27fd112869bd35afc0f374))
LIBRESPOT_SITE = $(call github,wesc,librespot,$(LIBRESPOT_VERSION))
LIBRESPOT_CARGO_BUILD_OPTS = $(call qstrip,$(BR2_PACKAGE_LIBRESPOT_BUILD_OPTS))
LIBRESPOT_DEPENDENCIES += host-rust-bindgen70 alsa-lib openssl

define LIBRESPOT_INSTALL_INIT_SYSTEMD
	# install systemd service file
	$(INSTALL) -D -m 0644 $(LIBRESPOT_PKGDIR)/librespot.service $(TARGET_DIR)/usr/lib/systemd/system/librespot.service

	# enable systemd service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -sf /usr/lib/systemd/system/librespot.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/librespot.service

	# create configuration file
	mkdir -p $(TARGET_DIR)/etc/default/
	echo "# librespot configuration" > $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_NAME=\"$(BR2_PACKAGE_LIBRESPOT_CONF_NAME)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_DEVICE_TYPE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_DEVICE_TYPE)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_SYSTEM_CACHE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_SYSTEM_CACHE)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_CACHE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_CACHE)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_VOLUME_CTRL=\"$(BR2_PACKAGE_LIBRESPOT_CONF_VOLUME_CTRL)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_BITRATE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_BITRATE)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_CACHE_SIZE_LIMIT=\"$(BR2_PACKAGE_LIBRESPOT_CONF_CACHE_SIZE_LIMIT)\"" >> $(TARGET_DIR)/etc/default/librespot
endef

$(eval $(cargo-package))
