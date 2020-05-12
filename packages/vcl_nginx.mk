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

vcl_nginx_version            := 1.14.2
vcl_nginx_patch_dir          := $(CURDIR)/nginx_patches
vcl_nginx_src_dir            := $(B)/vcl_nginx
vcl_vpp_src_dir              := $(CURDIR)/vpp
vcl_nginx_install_dir        := $(I)/local/nginx
vcl_nginx_deb_inst_dir       := /usr/local/nginx
vcl_nginx_pkg_deb_name       := nginx
vcl_nginx_pkg_deb_dir        := $(I)/vcl-deb
vcl_nginx_tarball            := nginx-$(vcl_nginx_version).tar.gz
vcl_nginx_tarball_strip_dirs := 1
vcl_nginx_desc               := "vcl nginx"


define  vcl_nginx_patch_cmds
	@for f in $(vcl_nginx_patch_dir)/*.patch ; do \
		echo "Applying patch: $$(basename $$f)" ; \
		patch -p2 -d $(vcl_nginx_src_dir) < $$f ; \
	done
endef

define  vcl_nginx_config_cmds
	@cd $(vcl_nginx_src_dir); \
	./configure --prefix=$(vcl_nginx_install_dir) --with-vcl \
		--vpp-lib-path=$(vcl_vpp_src_dir)/build-root/install-vpp-native/vpp/lib \
		--vpp-src-path=$(vcl_vpp_src_dir)/src
endef

define  vcl_nginx_build_cmds
	@$(MAKE) -C $(vcl_nginx_src_dir)
endef

define  vcl_nginx_install_cmds
	@$(MAKE) -C $(vcl_nginx_src_dir) install
	@cp configs/mime.types $(vcl_nginx_install_dir)/conf/.
	@cp configs/nginx.conf $(vcl_nginx_install_dir)/conf/.
	@cp configs/tls-* $(vcl_nginx_install_dir)/conf/.
	@cp configs/vcl.conf $(vcl_nginx_install_dir)/conf/.
endef

define vcl_nginx_pkg_deb_cmds
	@fpm -f -s dir \
		-t deb \
		-n $(vcl_nginx_pkg_deb_name) \
		-v $(vcl_nginx_version) \
		-C $(vcl_nginx_install_dir) \
		-p $(vcl_nginx_pkg_deb_dir) \
		--prefix $(vcl_nginx_deb_inst_dir) \
		--license $(LICENSE) \
		--iteration $(LINUX_ITER) \
		--vendor Intel \
		--description $(vcl_nginx_desc) \
		--deb-no-default-config-files \
		--pre-install pre-install
endef

define  vcl_nginx_pkg_deb_cp_cmds
	@echo "--- copy deb to $(CURDIR)/deb-vcl ---"
	@cp $(vcl_nginx_pkg_deb_dir)/*.deb deb-vcl/.
endef

$(eval $(call package,vcl_nginx))
