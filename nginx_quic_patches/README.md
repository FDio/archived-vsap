

Introduction
===========
    QUIC protocol requires each packet to do two rounds of encryption, that is, one total packet level encryption, and one header protection encryption, thus when QUIC needs to send out a big chunk of file to the peer, for example, a 1M file, the normal working flow for QUIC is to separate the file into multiple L2 packets, and for each packet to do 2 rounds of encryption, and the crypto size is below MTU. 

    We propose an innovative idea to accelerate QUIC protocol encryption by designing and implementing a batch mode encryption operation which could perform multiple small size crypto operations simultaneously and accelerate the overall QUIC performance. This work is highly linked to Intel features such as AVX512, and vector AES instructions, which is typically beneficial on Intel. 

Besides, we have implemented the acceleration algorithm based on Intel vector AES instruction, and the report shows that we can achieve 40% performance improvement in QUIC performance testing.  

Architecture
===========
1> Packet Protection
    In one QUIC session, due to the limitation of MTU (normally 1500 bytes), when QUIC sends out a big file to the peer, multiple QUIC packets need to be generated and protected via AEAD operation.
2> Header Protection
    is the process in which part of QUIC header is protected with a key that is derived from protected packet and can only be applied after protecting the payload. 


Code base
=========
Nginx
    Repo: https://hg.nginx.org/nginx-quic
    CommitID: 7871:c2f5d79cde64

Boringssl
    Repo: https://github.com/google/boringssl
    CommitID: a75bee541428228714696dbff72d33f20b6899da

IPsec-mb (to be updated)
    Repo: https://github.com/intel-innersource/libraries.performance.ipsec-mb.git
    CommitID: dev_quic_gcm_api

Patch
    git apply nginx_hp_ep.patch 

Build
=====
IPsec-mb
    cd libraries.performance.ipsec-mb
    make SHARED=n

boringssl	
    cd boringssl
    mkdir build
    cd build
    cmake ..
    make

Nginx-quic	
    cd nginx-quic-ipsecmb/
    ./auto/configure --with-debug --with-http_v3_module \
            --with-select_module \
            --with-cc-opt='-I../boringssl/include -I../libraries.performance.ipsec-mb/lib'  \
            --with-ld-opt='-L../boringssl/build/ssl -L../boringssl/build/crypto -L../libraries.performance.ipsec-mb/lib'
    make

Configuration
=============
1. Add the 'quic_gso on;' directive in the ‘nginx_ref.conf’ 


Performance
===========
Platform:CLX
-----------
Object              Gbits/s     Speed up
Nginx-org           3.051        100%
Nginx-patched       4.341        142%

Platform:ICX
------------
Object              Gbits/s     Speed up
Nginx-org           4.33        100%
Nginx-patched       6.26        145%


