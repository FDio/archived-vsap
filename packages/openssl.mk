# Copyright (c) 2018 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

openssl_version            := 3.0.0-alpha1
openssl_patch_dir          := $(CURDIR)/patches/openssl
openssl_install_dir        := $(I)/local/ssl
openssl_deb_inst_dir       := /usr/local/ssl
openssl_pkg_deb_name       := openssl3
openssl_pkg_deb_dir        := $(I)/openssl-deb
openssl_rpm_inst_dir       := /usr/local/ssl
openssl_pkg_rpm_name       := openssl3
openssl_pkg_rpm_dir        := $(I)/openssl-rpm
openssl_tarball            := openssl-$(openssl_version).tar.gz
openssl_tarball_md5sum     := d9326bd068a0382193ab0cb1c6e4685b
openssl_tarball_strip_dirs := 1
openssl_url                := https://www.openssl.org/source/$(openssl_tarball)
openssl_desc               := "openssl3.0.0"

define  openssl_config_cmds
	@cd $(openssl_build_dir) && \
		$(openssl_src_dir)/config \
		--prefix=$(openssl_install_dir) shared zlib
endef

define  openssl_build_cmds
	@$(MAKE) -C $(openssl_build_dir) depend
	@$(MAKE) -C $(openssl_build_dir)
	@$(MAKE) -C $(openssl_build_dir) install
endef

define  openssl_install_cmds
	@true
endef


$(eval $(call package,openssl))
