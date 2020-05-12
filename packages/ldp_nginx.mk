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

ldp_nginx_version            := 1.14.2
ldp_nginx_src_dir            := $(B)/ldp_nginx
ldp_nginx_install_dir        := $(I)/local/nginx
ldp_nginx_deb_inst_dir       := /usr/local/nginx
ldp_nginx_pkg_deb_name       := nginx
ldp_nginx_pkg_deb_dir        := $(I)/ldp-deb
ldp_nginx_tarball            := nginx-$(ldp_nginx_version).tar.gz
ldp_nginx_tarball_strip_dirs := 1
ldp_nginx_desc               := "ldp nginx"


define  ldp_nginx_patch_cmds
	@true
endef

define  ldp_nginx_config_cmds
	@cd $(ldp_nginx_src_dir); \
	./configure --prefix=$(ldp_nginx_install_dir) \
		--with-http_stub_status_module \
		--with-http_ssl_module
endef

define  ldp_nginx_build_cmds
	@$(MAKE) -C $(ldp_nginx_src_dir)
endef

define  ldp_nginx_install_cmds
	@$(MAKE) -C $(ldp_nginx_src_dir) install
	@cp configs/mime.types $(vcl_nginx_install_dir)/conf/.
	@cp configs/nginx.conf $(vcl_nginx_install_dir)/conf/.
	@cp configs/tls-* $(vcl_nginx_install_dir)/conf/.
	@cp configs/vcl.conf $(vcl_nginx_install_dir)/conf/.
endef

define ldp_nginx_pkg_deb_cmds
	@fpm -f -s dir \
		-t deb \
		-n $(ldp_nginx_pkg_deb_name) \
		-v $(ldp_nginx_version) \
		-C $(ldp_nginx_install_dir) \
		-p $(ldp_nginx_pkg_deb_dir) \
		--prefix $(ldp_nginx_deb_inst_dir) \
		--license $(LICENSE) \
		--iteration $(LINUX_ITER) \
		--vendor Intel \
		--description $(ldp_nginx_desc) \
		--deb-no-default-config-files \
		--pre-install pre-install
endef

define  ldp_nginx_pkg_deb_cp_cmds
	@echo "--- copy deb to $(CURDIR)/deb-ldp ---"
	@cp $(ldp_nginx_pkg_deb_dir)/*.deb deb-ldp/.
endef

$(eval $(call package,ldp_nginx))
