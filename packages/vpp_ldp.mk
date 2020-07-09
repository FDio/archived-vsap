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

vpp_ldp_patch_dir          := $(CURDIR)/vpp_patches
vpp_ldp_src_dir            := $(CURDIR)/vpp
vpp_ldp_install_dir        := $(I)/local
vpp_ldp_pkg_deb_name       := vpp
vpp_ldp_pkg_deb_dir        := $(CURDIR)/vpp/build-root
vpp_ldp_desc               := "ldp vpp"
openssl_install_dir        ?= /usr/local/ssl
openssl_github_2005patch   := $(CURDIR)/vpp_patches/other/2005/github

define  vpp_ldp_extract_cmds
	@true
endef

define  vpp_ldp_patch_cmds
	@echo "--- ldp vpp patching ---"
	@cd $(vpp_ldp_src_dir); \
		git reset --hard; git clean -f; git checkout master; \
		if [ $(_VPP_VER) != "master" ] ; then \
			echo "--- vpp version: $(_VPP_VER) ---"; \
			if [ $(_VPP_VER) = "2005" ]; then \
				git checkout v20.05; \
			elif [ $(_VPP_VER) = "2001" ]; then \
				git checkout v20.01; \
			fi; \
			git reset --hard; git clean -f; \
		fi
	@for f in $(CURDIR)/vpp_patches/common/*.patch ; do \
		echo Applying patch: $$(basename $$f) ; \
		patch -p1 -d $(vpp_ldp_src_dir) < $$f ; \
	done
	@if [ $(openssl3_enable) = 1 ]; then \
		for f in $(CURDIR)/vpp_patches/other/*.patch ; do \
			echo Applying patch: $$(basename $$f) ; \
			patch -p1 -d $(vpp_vcl_src_dir) < $$f ; \
		done; \
		if [ $(_VPP_VER) = "master" ]; then \
			echo "--- vpp master ---"; \
			for f in $(CURDIR)/vpp_patches/other/master/*; do \
				echo Applying patch: $$(basename $$f) ; \
				patch -p1 -d $(vpp_ldp_src_dir) < $$f ; \
			done; \
		elif [ $(_VPP_VER) = "2005" ]; then \
			echo "--- vpp 20.05 ---"; \
			if [ $(openssl_github) = 1 ]; then \
				for f in $(openssl_github_2005patch)/*.patch;do\
					echo Applying patch: $$(basename $$f) ;\
					patch -p1 -d $(vpp_vcl_src_dir) < $$f ;\
				done; \
			else \
			for f in $(CURDIR)/vpp_patches/other/2005/*.patch ;do \
				echo Applying patch: $$(basename $$f) ; \
				patch -p1 -d $(vpp_ldp_src_dir) < $$f ; \
			done; \
			fi; \
		elif [ $(_VPP_VER) = "2001" ]; then \
			echo "--- vpp 20.01 ---"; \
			for f in $(CURDIR)/vpp_patches/other/2001/*.patch ;do \
				echo Applying patch: $$(basename $$f) ; \
				patch -p1 -d $(vpp_ldp_src_dir) < $$f ; \
			done; \
		fi; \
	fi
	@if [ $(_VPP_VER) = "master" ]; then \
		echo "--- patch master ---"; \
		for f in $(CURDIR)/vpp_patches/ldp/master/*.patch ; do \
			echo Applying patch: $$(basename $$f) ; \
			patch -p1 -d $(vpp_ldp_src_dir) < $$f ; \
		done; \
	elif [ $(_VPP_VER) = "2005" ]; then \
		echo "--- patch v20.05 ---"; \
		for f in $(CURDIR)/vpp_patches/ldp/2005/*.patch ; do \
			echo Applying patch: $$(basename $$f) ; \
			patch -p1 -d $(vpp_ldp_src_dir) < $$f ; \
		done; \
	elif [ $(_VPP_VER) = "2001" ]; then \
		echo "--- patch 2001 ---"; \
		for f in $(CURDIR)/vpp_patches/ldp/2001/*.patch ; do \
			echo Applying patch: $$(basename $$f) ; \
			patch -p1 -d $(vpp_ldp_src_dir) < $$f ; \
		done; \
	fi
	@true
endef


define  vpp_ldp_config_cmds
	@true
endef

define  vpp_ldp_build_cmds
	@cd $(vpp_ldp_src_dir); \
	echo "---build : $(vpp_ldp_src_dir)"; \
		if [ $(openssl3_enable) = 1 ]; then \
			export OPENSSL_ROOT_DIR=$(openssl_install_dir); \
			export LD_LIBRARY_PATH=$(openssl_install_dir)/lib; \
		fi; \
		$(MAKE) wipe-release; $(MAKE) wipe; \
		cd build-root; $(MAKE) distclean; cd ..; \
		if [ $(debug) = 1 ]; then $(MAKE) build; \
		else $(MAKE) build-release; \
		fi; \
		$(MAKE) pkg-deb;
endef

define  vpp_ldp_install_cmds
	@true
endef

define  vpp_ldp_pkg_deb_cmds
	@true
endef

define  vpp_ldp_pkg_deb_cp_cmds
	@echo "--- move deb to $(CURDIR)/deb-ldp ---"
	@mkdir -p deb-ldp
	@ls deb-ldp/ ;rm -f deb-ldp/*
	@mv $(I)/openssl-deb/*.deb .
	@rm $(B)/.openssl.pkg-deb.ok
	@mv $(vpp_ldp_pkg_deb_dir)/*.deb deb-ldp/.
endef

$(eval $(call package,vpp_ldp))
