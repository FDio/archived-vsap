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

nginx_version            := 1.14.2
nginx_tarball            := nginx-$(nginx_version).tar.gz
nginx_tarball_md5sum     := 239b829a13cea1d244c1044e830bd9c2
nginx_url                := http://nginx.org/download/$(nginx_tarball)


$(eval $(call download,nginx))
