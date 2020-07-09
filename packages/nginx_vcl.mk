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

nginx_vcl_version            := 1.14.2
nginx_vcl_patch_dir          := $(CURDIR)/nginx_patches
nginx_vcl_src_dir            := $(B)/nginx_vcl
vpp_vcl_src_dir              := $(CURDIR)/vpp
nginx_vcl_install_dir        := /usr/local/nginx
nginx_vcl_deb_inst_dir       := /usr/local/nginx
nginx_vcl_pkg_deb_name       := nginx
nginx_vcl_pkg_deb_dir        := $(I)/deb-vcl
nginx_vcl_tarball            := nginx-$(nginx_vcl_version).tar.gz
nginx_vcl_tarball_strip_dirs := 1
nginx_vcl_desc               := "vcl nginx"

vsap_vcl_pkg_deb_name        := vsap-vcl
vsap_vcl_version             := 1.0
vsap_vcl_install_dir         := $(CURDIR)/root
vsap_vcl_pkg_deb_dir         := $(CURDIR)/
vsap_vcl_deb_inst_dir        := /
vsap_vcl_desc                := "vsap vcl"

define  nginx_vcl_patch_cmds
	@for f in $(nginx_vcl_patch_dir)/*.patch ; do \
		echo "Applying patch: $$(basename $$f)" ; \
		patch -p2 -d $(nginx_vcl_src_dir) < $$f ; \
	done
endef

define  nginx_vcl_config_cmds
	@cd $(nginx_vcl_src_dir); \
	./configure --prefix=$(nginx_vcl_install_dir) --with-vcl \
		--vpp-lib-path=$(vpp_vcl_src_dir)/build-root/install-vpp-native/vpp/lib \
		--vpp-src-path=$(vpp_vcl_src_dir)/src
endef

define  nginx_vcl_build_cmds
	@$(MAKE) -C $(nginx_vcl_src_dir)
endef

define  nginx_vcl_install_cmds
	@$(MAKE) -C $(nginx_vcl_src_dir) install
	@cp configs/mime.types $(nginx_vcl_install_dir)/conf/.
	@cp configs/nginx.conf $(nginx_vcl_install_dir)/conf/.
	@cp configs/tls-* $(nginx_vcl_install_dir)/conf/.
	@cp configs/vcl.conf $(nginx_vcl_install_dir)/conf/.
endef

define nginx_vcl_pkg_deb_cmds
	@fpm -f -s dir \
		-t deb \
		-n $(nginx_vcl_pkg_deb_name) \
		-v $(nginx_vcl_version) \
		-C $(nginx_vcl_install_dir) \
		-p $(nginx_vcl_pkg_deb_dir) \
		--prefix $(nginx_vcl_deb_inst_dir) \
		--license $(LICENSE) \
		--iteration $(LINUX_ITER) \
		--vendor Intel \
		--description $(nginx_vcl_desc) \
		--deb-no-default-config-files \
		--pre-install packages/pre-install
endef

define  nginx_vcl_pkg_deb_cp_cmds
	@echo "--- move deb to $(CURDIR)/deb-vcl ---"
	@mv $(nginx_vcl_pkg_deb_dir)/*.deb deb-vcl/.
	@for f in deb-vcl/*.deb ; do \
		dpkg -x $$f root ; \
	done
	@fpm -f -s dir \
		-t deb \
		-n $(vsap_vcl_pkg_deb_name) \
		-v $(vsap_vcl_version) \
		-C $(vsap_vcl_install_dir) \
		-p $(vsap_vcl_pkg_deb_dir) \
		--prefix $(vsap_vcl_deb_inst_dir) \
		--license $(LICENSE) \
		--iteration $(LINUX_ITER) \
		--vendor Intel \
		--description $(vsap_vcl_desc) \
		--pre-install packages/pre-install \
		--post-install packages/post-install \
		--before-remove packages/pre-remove \
		--deb-no-default-config-files

	@for f in *.deb ; do \
		echo "Move package {:path=>$(CURDIR)/deb-vcl/$$f }"  ; \
	done
	@rm -rf root; rm deb-vcl/*.deb; mv *.deb deb-vcl/
endef

$(eval $(call package,nginx_vcl))
