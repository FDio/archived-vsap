# Copyright (c) 2020 Intel and/or its affiliates.
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

openssl_install_dir        := /usr/local/ssl
openssl_deb_inst_dir       := /usr/local/ssl
openssl_pkg_deb_name       := openssl3
openssl_pkg_deb_dir        := $(I)/openssl-deb
openssl_rpm_inst_dir       := /usr/local/ssl
openssl_pkg_rpm_name       := openssl3
openssl_pkg_rpm_dir        := $(I)/openssl-rpm
openssl_tarball_strip_dirs := 1
openssl_desc               := "openssl3.0.0"

ifeq ($(openssl_github),1)
define  openssl_download_cmds
	@echo "---download openssl ---";
	@cd downloads; git clone $(openssl_github_url);
endef

define  openssl_checksum_cmds
	@true
endef

define  openssl_extract_cmds
	@cp -rf downloads/openssl $(openssl_src_dir)
	@cd $(openssl_src_dir);git reset --hard $(openssl_commit);git clean -f;
endef
endif

define  openssl_patch_cmds
	@true
endef

define  openssl_config_cmds
	@cd $(openssl_src_dir); ./config \
		--prefix=$(openssl_install_dir) shared zlib
endef

define  openssl_build_cmds
	@$(MAKE) -C $(openssl_src_dir) depend
	@$(MAKE) -C $(openssl_src_dir)
	@$(MAKE) -C $(openssl_src_dir) install
endef

define  openssl_install_cmds
	@true
endef


$(eval $(call package,openssl))
