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
define h1
	@echo "--- $(1)"
endef

define download

##############################################################################
# Download
##############################################################################
ifeq ($$(call $1_download_cmds),)
define $1_download_cmds
	@if [ -e $(DL_CACHE_DIR)/$($1_tarball) ] ; \
		then cp $(DL_CACHE_DIR)/$($1_tarball) $$@ ; \
	else \
		echo "Downloading $($1_url)" ; \
		curl -o $$@ -LO $($1_url) ; \
	fi
endef
endif

downloads/$($1_tarball):
	mkdir -p downloads
	$$(call h1,"download $($1_tarball) ")
	$$(call $1_download_cmds)
	@rm -f $(B)/.$1.download.ok

ifeq ($$(call $1_checksum_cmds),)
define $1_checksum_cmds
	$$(call h1,"validating $1 $($1_version) checksum")
	@SUM=$$(shell openssl md5 $$< | cut -f 2 -d " " -) ; \
	([ "$$$${SUM}" = "$($1_tarball_md5sum)" ] || \
	( echo "========================================================" && \
	echo "Bad Checksum!" && \
	echo "Expected:   $($1_tarball_md5sum)" && \
	echo "Calculated: $$$${SUM}" && \
	echo "Please remove $$< and retry" && \
	echo "========================================================" && \
	false ))
endef
endif

$(B)/.$1.download.ok: downloads/$($1_tarball)
	@mkdir -p $(B)
	$$(call $1_checksum_cmds)
	@touch $$@

.PHONY: $1-dl
$1-dl: $(B)/.$1.download.ok


ALL_TARGETS += $1-dl
endef
