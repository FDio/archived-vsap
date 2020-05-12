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

ifneq ($(shell uname),Darwin)
	OS_ID        := $(shell grep '^ID=' /etc/os-release | cut -f2- -d= | sed -e 's/\"//g')
	OS_VERSION_ID:= $(shell grep '^VERSION_ID=' /etc/os-release | cut -f2- -d= | sed -e 's/\"//g')
else
	$(warning exit)
	@exit 1;
endif

# Scripts require non-POSIX parts of bash
SHELL := /bin/bash

export BR=$(CURDIR)

DL_CACHE_DIR = $(CURDIR)/downloads
MAKE ?= make
MAKE_ARGS ?= -j
BUILD_DIR        ?= $(CURDIR)/_build
INSTALL_DIR      ?= $(CURDIR)/_install

B := $(BUILD_DIR)
I := $(INSTALL_DIR)

_VPP_VER := $(vpp)


LINUX_ITER := $(OS_ID)$(OS_VERSION_ID)
LICENSE := BSD

.PHONY: help
help:
	@echo "Make Targets:"
	@echo " dep             - install software dependencies"
	@echo " deb-vcl         - build vcl DEB package"
	@echo " build-vcl       - build vcl vpp and vcl nginx"
	@echo " deb-ldp         - build ldp DEB package"
	@echo " build-ldp       - build ldp vpp and ldp nginx"
	@echo " clean           - clean up build environment."
	@echo " clean-vcl       - clean up build vcl environment."
	@echo " clean-ldp       - clean up build ldp environment."
	@echo ""

include packages.mk
include package.mk
include packages/openssl-dl.mk
include packages/nginx-dl.mk
include packages/openssl.mk
include packages/vcl_vpp.mk
include packages/ldp_vpp.mk
include packages/vcl_nginx.mk
include packages/ldp_nginx.mk

.PHONY: clean
clean:
	@rm -rf $(B) $(I)

.PHONY: clean-vcl
clean-vcl:
	@rm -f $(B)/.vcl*

.PHONY: clean-ldp
clean-ldp:
	@rm -f $(B)/.ldp*

$(BR)/.deps.ok:
	make dep
	@cd vpp; echo yes|make install-dep;
	@touch $@

.PHONY: build-vcl
build-vcl: openssl-dl nginx-dl openssl-build vcl_vpp-build vcl_nginx-build

.PHONY: build-ldp
build-ldp: openssl-dl nginx-dl openssl-build ldp_vpp-build ldp_nginx-build


.PHONY: deb-vcl
deb-vcl: $(BR)/.deps.ok build-vcl openssl-deb vcl_vpp-deb vcl_nginx-deb

.PHONY: deb-ldp
deb-ldp: $(BR)/.deps.ok build-ldp openssl-deb ldp_vpp-deb ldp_nginx-deb

.PHONY: dep
dep:
ifeq ($(OS_ID),ubuntu)
	@sudo -E apt-get update
	@sudo -E apt-get install git gcc make \
		ruby ruby-dev libpam0g-dev \
		libmariadb-client-lgpl-dev \
		libmysqlclient-dev -y
	@sudo -E gem install fpm
endif
