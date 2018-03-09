#!/bin/bash
ins_jdk(){
    cd /init_assets
    rpm -e ${remove_jdk_rpm}
    rpm -ivh ${install_jdk_rpm}
}

case "$1" in
    "1.7")
        echo "install jdk 1.7"
        install_jdk_rpm="jdk-7u121-linux-x64.rpm"
        remove_jdk_rpm="jdk1.7.0_121-1.8.0_121-fcs.x86_64"
        ;;
    *)
        echo "install jdk 1.8"
        install_jdk_rpm="jdk-8u121-linux-x64.rpm"
        remove_jdk_rpm="jdk1.8.0_121-1.8.0_121-fcs.x86_64"
        ;;
esac
ins_jdk;
