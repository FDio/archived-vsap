# 1 Introduction
This repository is to provide an optimized NGINX based on VPP host stack.
We provide two ways of VPP host stack integration, that is, the LDP and the VCL.
LDP is basically un-modified NGINX with VPP via LD_PRELOAD, while VCL NGINX is to integrate VPP host stack directly with NGINX code change.
This repository provides the initial nginx build and openssl3.0.0 build, as well as the integration of two VPP host stacks, namely the LDP and VCL VPP and nginx builds, and generates the installation package to the specified location.

# 2 Repository Layout
**configs**: configuration files for VPP, NGINX and VCL

**nginx_patches**: VCL patches for NGINX

**vpp_patches**: lock-free LDP and pinned-VPP patches

**ngxvcl_demo**: UI demo of ngxvcl performance test for Intel Network Thechnology Workshop 2019

**scripts**: scripts for VPP, NGINX and client test

**packages**: Makefiles for building and downloading

**patches**: openssl patches

# 3 Building on top of distinct patches

You can choose to use the Makefile to build automatically, and there are some Makefile options for you.

```bash
git clone --recursive https://gerrit.fd.io/r/vsap

Help
$ make help

Install software dependencies
$ make dep

Build vcl DEB package and store the DEB files in folder '/path/to/this/repo/deb-vcl'
$ make deb-vcl

Build vcl vpp and vcl nginx and store the vcl files in folder '/path/to/this/repo/_install/local'
$ make build-vcl

Build ldp DEB package and store the DEB files in folder '/path/to/this/repo/deb-ldp'
$ make deb-ldp

Build ldp vpp and ldp nginx and store the vcl files in folder '/path/to/this/repo/_install/local'
$ make build-ldp

Clean all packages
$ make clean
```

## 3.0 Basic patch

### 3.0.1 Application Worker Partition
**Functionality**

For both VCL and LDP, it requires to add a patch first to app worker optimization.
The upstream effort is ongoing, and if it is got accepted, then this patch is not necessary.

**Instructions**

```bash
$ cd /path/to/vpp
$ patch -p1 < /path/to/this/repo/vpp_patches/common/0001-session-pinning.patch
$ make build && make build-release
```

## 3.1 VCL NGINX

### 3.1.1 VPP side setting
VCL NGINX integration requires a patch inside VPP first.

```bash
$ cd /path/to/vpp
$ patch -p1 < /path/to/this/repo/vpp_patches/vcl/0001-ngxvcl-api.patch
$ make build && make build-release
```

### 3.1.2 NGINX side setting

Our repo has provided the modified code based on NGINX 1.14.2. You can either directly use our modified Nginx version or patch NGINX 1.14.2 by the provided patch.

```bash
$ cd /path/to/this/repo
$ cd nginx
```

or

```bash
$ cd path/to/your/own/nginx-1.14.2
$ patch -p2 < path/to/this/repo/nginx_patches/0001-ngxvcl.patch
```

Now the original NGINX code has been modified to VCL-supporting code.

Then you can configure and build NGINX.

```bash
$ ./configure --with-vcl --vpp-lib-path=/path/to/vpp/build-root/install-vpp-native/vpp/lib --vpp-src-path=/path/to/vpp/src
$ sudo make install
```

### 3.1.3 Run NgxVCL
- Run VPP first

  - Refer to startup.conf provided in "configs" to start VPP. (learn how to use startup.conf in section 4.1.1)
  - If you choose to use the Makefile to build automatically, the VPP is stored in '/path/to/this/repo/_install/local/vpp'

  ```bash
  ./vpp -c /path/to/startup.conf
  ```

  Start NGINX

  - refer to vcl.conf and nginx.conf provided under "configs"
  - If you choose to use the Makefile to build automatically, the NGINX is stored in '/path/to/this/repo/_install/local/nginx'

  ```
  # export VCL_CONFIG=/path/to/vcl.conf
  # export LD_LIBRARY_PATH=/path/to/vpp/build-root/install-vpp-native/vpp/lib
  # /usr/local/nginx/sbin/nginx -c /path/to/nginx.conf
  ```

## 3.2 LDP NGINX

### 3.2.1 Removing VLS Locks
**Functionality**

This patch removes VLS session locks for saving approximately 100% CPU cycles one core
of applications, especially for the application who is CPU-intensive.

**Instructions**

You may need root privilege.

```bash
$ cd /path/to/vpp
$ patch -p1 < /path/to/this/repo/vpp_patches/ldp/0001-LDP-remove-lock.patch
$ make build && make build-release
```
**Start NGINX**
If you choose to use the Makefile to build automatically, the VPP is stored in '/path/to/this/repo/_install/local/vpp'
If you choose to use the Makefile to build automatically, the NGINX is stored in '/path/to/this/repo/_install/local/nginx'

```bash
$ export VCL_CONFIG=path/to/vcl.conf
$ LD_PRELOAD=path/to/vpp/build-root/install-vpp-native/vpp/lib/libvcl_ldpreload.so /usr/local/nginx/sbin/nginx -c path/to/nginx.conf
```

## 3.3 Enable VPP TLS

### 3.3.1 Enable VPP TLS for VCL NGINX
If TLS is supproted, then before you run VCL NGINX, export following environment variables.

```bash
$ export NGXVCL_TLS_ON=1
$ export NGXVCL_TLS_CERT=/path/to/this/repo/configs/tls-test-cert
$ export NGXVCL_TLS_KEY=/path/to/this/repo/configs/tls-test-key
```

### 3.3.2 Enable VPP TLS for LDP NGINX

Before you run LDP NGINX, export following environment variables.

```bash
$ export LDP_TRANSPARENT_TLS=1
$ export LDP_TLS_CERT_FILE=/path/to/this/repo/configs/tls-test-cert
$ export LDP_TLS_KEY_FILE=/path/to/this/repo/configs/tls-test-key
```

# 4 Instances

## 4.1 NGINX + VPP

### 4.1.1 Used startup.conf
Inside startup.conf, you need to configure the following several directives:
- pci-address: the pci address of NIC. Refer to [dpdk_bind_driver](http://doc.dpdk.org/guides/linux_gsg/linux_drivers.html) to bind NIC to the vfio-pci driver at first.
- socket-name path/to/vpp-api.sock: socket which would be used to connect VPP and NGINX. This sock should also be configured in vcl.conf.

### 4.1.2 Notes
Please ensure that the processes of NGINX and VPP run on same NUMA node as the used NIC.

**VPP**

The core number could be selected via two arguments:

```bash
main-core 0             ##set vpp master on core 0
corelist-workers 1-4    ##set the four vpp worker threads on core 1-4,
                        ##If start 8 VPP worker, the value should be 1-8 or x-(x+7)
num-rx-queues 4         ##Assign each VPP worker one rx queue.
```

**Set core affinity for NGINX processes**

In order to make all nginx workers run on NUMA node as same as VPP, we provide one way using tool named taskset.
And the relative commands are followed, you may need to change the number of nginx worker processes, which is ***for i in `seq 1 4`; do***, the `4` should be same as the number of started NGINX workers.

### 4.1.3 Performance

Our performance test is based on "wrk", and some scripts are provided in directory of "scripts". The script is  for internal usage only now and some code is hard-coded.
