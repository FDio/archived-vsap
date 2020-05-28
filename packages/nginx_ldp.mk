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

nginx_ldp_version            := 1.14.2
nginx_ldp_src_dir            := $(B)/nginx_ldp
nginx_ldp_install_dir        := /usr/local/nginx
nginx_ldp_deb_inst_dir       := /usr/local/nginx
nginx_ldp_pkg_deb_name       := nginx
nginx_ldp_pkg_deb_dir        := $(I)/deb-ldp
nginx_ldp_tarball            := nginx-$(nginx_ldp_version).tar.gz
nginx_ldp_tarball_strip_dirs := 1
nginx_ldp_desc               := "ldp nginx"


define  nginx_ldp_patch_cmds
	@true
endef

define  nginx_ldp_config_cmds
	@cd $(nginx_ldp_src_dir); \
	./configure --prefix=$(nginx_ldp_install_dir) \
		--with-http_stub_status_module \
		--with-http_ssl_module
endef

define  nginx_ldp_build_cmds
	@$(MAKE) -C $(nginx_ldp_src_dir)
endef

define  nginx_ldp_install_cmds
	@$(MAKE) -C $(nginx_ldp_src_dir) install
	@cp configs/mime.types $(nginx_ldp_install_dir)/conf/.
	@cp configs/nginx.conf $(nginx_ldp_install_dir)/conf/.
	@cp configs/tls-* $(nginx_ldp_install_dir)/conf/.
	@cp configs/vcl.conf $(nginx_ldp_install_dir)/conf/.
endef

define nginx_ldp_pkg_deb_cmds
	@fpm -f -s dir \
		-t deb \
		-n $(nginx_ldp_pkg_deb_name) \
		-v $(nginx_ldp_version) \
		-C $(nginx_ldp_install_dir) \
		-p $(nginx_ldp_pkg_deb_dir) \
		--prefix $(nginx_ldp_deb_inst_dir) \
		--license $(LICENSE) \
		--iteration $(LINUX_ITER) \
		--vendor Intel \
		--description $(nginx_ldp_desc) \
		--deb-no-default-config-files \
		--pre-install packages/pre-install
endef

define  nginx_ldp_pkg_deb_cp_cmds
	@echo "--- move deb to $(CURDIR)/deb-ldp ---"
	@mv $(nginx_ldp_pkg_deb_dir)/*.deb deb-ldp/.
endef

$(eval $(call package,nginx_ldp))
