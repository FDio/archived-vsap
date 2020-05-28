#!/bin/bash

ngxvcl=${BR}/_build/nginx_vcl
ngxldp=${BR}/_build/nginx_ldp

function test_vcl(){
    export LD_LIBRARY_PATH=/usr/local/ssl/lib
    cp ${BR}/configs/startup.conf ${BR}/configs/startup-test.conf

    sed -i 's|/var/log/vpp/vpp.log|/tmp/vpp.log|' ${BR}/configs/startup-test.conf
    sed -i 's|cli-vpp1.sock|cli.sock|' ${BR}/configs/startup-test.conf
    sed -i 's|/path/to/configs/vppenvset|configs/vppset|' ${BR}/configs/startup-test.conf
    sed -i 's|socket-name /path/to/vpp-api.sock|default|' ${BR}/configs/startup-test.conf
    echo "set int state local0 up" > ${BR}/configs/vppset

    ${BR}/vpp/build-root/install-vpp-native/vpp/bin/vpp -c configs/startup-test.conf &
    vpp_pid=$!
    echo ${vpp_pid}

    sleep 5

    export VCL_CONFIG=${BR}/configs/vcl.conf

    export NGXVCL_TLS_ON=1
    export NGXVCL_TLS_CERT=${BR}/configs/tls-test-cert
    export NGXVCL_TLS_KEY=${BR}/configs/tls-test-key

    export LD_LIBRARY_PATH=${BR}/vpp/build-root/install-vpp-native/vpp/lib

    sudo killall -v -s 9 nginx || echo "continue execute"

    cp ${BR}/configs/nginx.conf ${BR}/configs/nginx-test.conf
    sed -i 's|#worker_processes 1|worker_processes 1|' ${BR}/configs/nginx-test.conf

    ${ngxvcl}/objs/nginx -c ${BR}/configs/nginx-test.conf &
    nginx_pid=$!
    sleep 5

    v=`ps -A|grep -E "${vpp_pid}|${nginx_pid}" | wc -l`
    sudo killall -v -s 9 nginx || echo ""
    sudo kill -9 ${vpp_pid} || echo ""
    rm -f ${BR}/configs/nginx-test.conf
    rm -f ${BR}/configs/startup-test.conf
    rm -f ${BR}/configs/vppset
    rm -f /tmp/vpp.log

    echo "===================================================================="
    if [ ${v} -eq 2 ]; then
        echo "VCL test                                                      OK"
        echo "===================================================================="
    else
        echo "VCL test                                                        FAIL"
        echo "===================================================================="
        exit 1
    fi
}

function test_ldp(){
    export LD_LIBRARY_PATH=/usr/local/ssl/lib
    cp ${BR}/configs/startup.conf ${BR}/configs/startup-test.conf

    sed -i 's|/var/log/vpp/vpp.log|/tmp/vpp.log|' ${BR}/configs/startup-test.conf
    sed -i 's|cli-vpp1.sock|cli.sock|' ${BR}/configs/startup-test.conf
    sed -i 's|/path/to/configs/vppenvset|configs/vppset|' ${BR}/configs/startup-test.conf
    sed -i 's|socket-name /path/to/vpp-api.sock|default|' ${BR}/configs/startup-test.conf
    echo "set int state local0 up" > ${BR}/configs/vppset

    ${BR}/vpp/build-root/install-vpp-native/vpp/bin/vpp -c configs/startup-test.conf &
    vpp_pid=$!

    sleep 5

    cp ${BR}/configs/nginx.conf ${BR}/configs/nginx-test.conf
    sed -i 's|#worker_processes 1|worker_processes 1|' ${BR}/configs/nginx-test.conf

    export VCL_CONFIG=${BR}/configs/vcl.conf
    export LDP_TRANSPARENT_TLS=1
    export LDP_TLS_CERT_FILE=${BR}/configs/tls-test-cert
    export LDP_TLS_KEY_FILE=${BR}/configs/tls-test-key
    LD_PRELOAD=${BR}/vpp/build-root/install-vpp-native/vpp/lib/libvcl_ldpreload.so \
        ${ngxldp}/objs/nginx -c ${BR}/configs/nginx-test.conf &

    nginx_pid=$!
    sleep 5

    v=`ps -A|grep -E "${vpp_pid}|${nginx_pid}" | wc -l`
    sudo killall -v -s 9 nginx || echo ""
    sudo kill -9 ${vpp_pid} || echo ""

    rm -f ${BR}/configs/nginx-test.conf
    rm -f ${BR}/configs/startup-test.conf
    rm -f ${BR}/configs/vppset
    rm -rf /tmp/vpp.log

    echo "===================================================================="
    if [ ${v} -eq 2 ]; then
        echo "LDP test                                                      OK"
        echo "===================================================================="
    else
        echo "LDP test                                                        FAIL"
        echo "===================================================================="
        exit 1
    fi
}

args=("$@")
case ${1} in
    vcl)
        test_vcl
        ;;
    ldp)
        test_ldp
        ;;
esac
