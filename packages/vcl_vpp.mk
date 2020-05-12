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

vcl_vpp_patch_dir          := $(CURDIR)/vpp_patches
vcl_vpp_src_dir            := $(CURDIR)/vpp
vcl_vpp_install_dir        := $(I)/local
vcl_vpp_pkg_deb_name       := vpp
vcl_vpp_pkg_deb_dir        := $(CURDIR)/vpp/build-root
vcl_vpp_desc               := "vcl vpp"


define  vcl_vpp_extract_cmds
	@true
endef

define  vcl_vpp_patch_cmds
	@echo "--- vcl vpp patching ---"
	@cd $(vcl_vpp_src_dir);git reset --hard; git clean -f;
	@for f in $(CURDIR)/vpp_patches/common/*.patch ; do \
		echo Applying patch: $$(basename $$f) ; \
		patch -p1 -d $(vcl_vpp_src_dir) < $$f ; \
	done
	@for f in $(CURDIR)/vpp_patches/vcl/*.patch ; do \
		echo Applying patch: $$(basename $$f) ; \
		patch -p1 -d $(vcl_vpp_src_dir) < $$f ; \
		done

	@true
endef


define  vcl_vpp_config_cmds
	@true
endef

define  vcl_vpp_build_cmds
	@cd $(vcl_vpp_src_dir); \
		echo "--- build : $(vcl_vpp_src_dir)"; \
		export OPENSSL_ROOT_DIR=$(I)/local/ssl; \
		export LD_LIBRARY_PATH=$(I)/local/ssl/lib; \
		$(MAKE) wipe-release; \
		$(MAKE) build-release; \
		$(MAKE) pkg-deb; \
		echo "--- Please wait for the final completion ..."; \
		cd ..; rm -rf $(vcl_vpp_install_dir); \
		cp -rf vpp $(vcl_vpp_install_dir); \
		echo "--- Completed! ---"
endef

define  vcl_vpp_install_cmds
	@true
endef

define  vcl_vpp_pkg_deb_cmds
	@true
endef

define  vcl_vpp_pkg_deb_cp_cmds
	@echo "--- copy deb to $(CURDIR)/dev-vcl ---"
	@mkdir -p deb-vcl
	@cp $(I)/openssl-deb/*.deb deb-vcl/.
	@cp $(vcl_vpp_pkg_deb_dir)/*.deb deb-vcl/.
endef

$(eval $(call package,vcl_vpp))
