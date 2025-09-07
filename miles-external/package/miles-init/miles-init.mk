################################################################################
#
# miles-init
#
################################################################################

MILES_INIT_VERSION = 1.0
MILES_INIT_LICENSE = MIT

define MILES_INIT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(MILES_INIT_PKGDIR)/miles-volume $(TARGET_DIR)/usr/bin/miles-volume
	$(INSTALL) -D -m 0644 $(MILES_INIT_PKGDIR)/asound.conf $(TARGET_DIR)/etc/asound.conf
endef

define MILES_INIT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 $(MILES_INIT_PKGDIR)/miles-volume.service $(TARGET_DIR)/usr/lib/systemd/system/miles-volume.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -sf /usr/lib/systemd/system/miles-volume.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/miles-volume.service
endef

$(eval $(generic-package))
