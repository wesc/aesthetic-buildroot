################################################################################
#
# librespot
#
################################################################################

LIBRESPOT_LICENSE = MIT
LIBRESPOT_VERSION = $(call qstrip,$(or $(BR2_PACKAGE_LIBRESPOT_VERSION),78ce118d32912adfb2705481f69c83df6a88211f))
LIBRESPOT_SITE = $(call github,wesc,librespot,$(LIBRESPOT_VERSION))
LIBRESPOT_CARGO_BUILD_OPTS = $(call qstrip,$(BR2_PACKAGE_LIBRESPOT_BUILD_OPTS))
LIBRESPOT_DEPENDENCIES += host-rust-bindgen alsa-lib openssl

define LIBRESPOT_INSTALL_INIT_SYSTEMD
	# install systemd service file
	$(INSTALL) -D -m 0644 $(LIBRESPOT_PKGDIR)/librespot.service $(TARGET_DIR)/usr/lib/systemd/system/librespot.service

	# create configuration file
	mkdir -p $(TARGET_DIR)/etc/default/
	echo "# librespot configuration" > $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_NAME=\"$(BR2_PACKAGE_LIBRESPOT_CONF_NAME)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_DEVICE_TYPE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_DEVICE_TYPE)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_SYSTEM_CACHE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_SYSTEM_CACHE)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_CACHE=\"/tmp/librespot\"" >> $(TARGET_DIR)/etc/default/librespot
	if [[ x$(BR2_PACKAGE_LIBRESPOT_CONF_DISABLE_DISCOVERY) == xy ]]; then \
		echo "LIBRESPOT_DISABLE_DISCOVERY=\"--disable-discovery\"" >> $(TARGET_DIR)/etc/default/librespot; \
	else \
		echo "LIBRESPOT_DISABLE_DISCOVERY=\"\"" >> $(TARGET_DIR)/etc/default/librespot; \
	fi
	if [[ x$(BR2_PACKAGE_LIBRESPOT_CONF_AUTOPLAY) == xy ]]; then \
		echo "LIBRESPOT_AUTOPLAY=\"--autoplay\"" >> $(TARGET_DIR)/etc/default/librespot; \
	else \
		echo "LIBRESPOT_AUTOPLAY=\"\"" >> $(TARGET_DIR)/etc/default/librespot; \
	fi
	echo "LIBRESPOT_VOLUME_CTRL=\"$(BR2_PACKAGE_LIBRESPOT_CONF_VOLUME_CTRL)\"" >> $(TARGET_DIR)/etc/default/librespot
	echo "LIBRESPOT_BITRATE=\"$(BR2_PACKAGE_LIBRESPOT_CONF_BITRATE)\"" >> $(TARGET_DIR)/etc/default/librespot
endef

$(eval $(cargo-package))
