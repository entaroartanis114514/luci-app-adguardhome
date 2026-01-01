include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-adguardhome
PKG_VERSION:=1.8-20221120
PKG_RELEASE:=1
PKG_MAINTAINER:=<https://github.com/rufengsuixing/luci-app-adguardhome>


include $(INCLUDE_DIR)/package.mk

define Package/luci-app-adguardhome
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI app for adguardhome
  PKGARCH:=all
  DEPENDS:=+!wget&&!curl&&!wget-ssl:curl +luci-base
endef

define Package/luci-app-adguardhome/description
 LuCI support for adguardhome
endef


PKG_BUILD_DEPENDS:=luci-base/host

define Package/luci-app-adguardhome/conffiles
/usr/share/AdGuardHome/links.txt
/etc/config/AdGuardHome
endef


define Build/Compile
endef

define Package/luci-app-adguardhome/postinst
#!/bin/sh
	/etc/init.d/AdGuardHome enable >/dev/null 2>&1
	enable=$$(uci get AdGuardHome.AdGuardHome.enabled 2>/dev/null)
	if [ "$$enable" == "1" ]; then
		/etc/init.d/AdGuardHome reload >/dev/null 2>&1
	fi
	rm -f /tmp/luci-indexcache
	rm -f /tmp/luci-modulecache/*
exit 0
endef

define Package/luci-app-adguardhome/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	 /etc/init.d/AdGuardHome disable
	 /etc/init.d/AdGuardHome stop >/dev/null 2>&1
uci -q batch <<-EOF_BATCH >/dev/null 2>&1
	delete ucitrack.@AdGuardHome[-1]
	commit ucitrack
EOF_BATCH
fi
exit 0
endef

define Package/luci-app-adguardhome/postrm
#!/bin/sh
rm -rf /etc/AdGuardHome/
exit 0
endef


define Package/luci-app-adguardhome/install

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -PR ./luasrc/* $(1)/usr/lib/lua/luci/ 2>/dev/null || true
	

	$(INSTALL_DIR) $(1)/
	cp -PR ./root/* $(1)/ 2>/dev/null || true
	

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/AdGuardHome.po $(1)/usr/lib/lua/luci/i18n/adguardhome.zh-cn.lmo
endef

$(eval $(call BuildPackage,luci-app-adguardhome))
