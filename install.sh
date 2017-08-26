#! /bin/bash

url='https://github.com/coreos/etcd/releases/download/v3.2.6/etcd-v3.2.6-linux-amd64.tar.gz'
package=`basename $url`
dir=`basename $url .tar.gz`

download_etcd()
{
    if [ ! -d etcd ];then
        echo test1
        if [ ! -f $package ];then
            ls $package
            echo test2
            wget $url
        fi
        tar xzf $package
        mv $dir etcd
    fi
}

install_etcd()
{
    test -d '/usr/local/etcd' || mkdir -p /usr/local/etcd
    test -d '/usr/local/etcd/bin' || mkdir -p /usr/local/etcd/bin
    test -d '/usr/local/etcd/conf' || mkdir -p /usr/local/etcd/conf
    test -d '/usr/local/etcd/data' || mkdir -p /usr/local/etcd/data

    #bin
    test ! -f '/usr/local/etcd/bin/etcd' || mv '/usr/local/etcd/bin/etcd' \
        '/usr/local/etcd/bin/etcd.old'
    test ! -f '/usr/local/etcd/bin/etcdctl' || mv '/usr/local/etcd/bin/etcdctl'\
        '/usr/local/etcd/bin/etcdctl.old'
    install etcd/etcd /usr/local/etcd/bin/etcd
    install etcd/etcdctl /usr/local/etcd/bin/etcdctl
    rm -f /usr/local/bin/etcd
    rm -f /usr/local/bin/etcdctl
    ln -s /usr/local/etcd/bin/etcd /usr/local/bin/etcd
    ln -s /usr/local/etcd/bin/etcdctl /usr/local/bin/etcdctl

    #conf
    test -f '/usr/local/etcd/conf/etcd.conf' || install conf/etcd.conf \
        '/usr/local/etcd/conf/etcd.conf'

    #service
    install etcd.service /usr/lib/systemd/system/etcd.service
}

granted_etcd()
{
    grep "^etcd" /etc/passwd >& /dev/null
    if [ $? -ne 0 ];then
        useradd etcd -M -r -d /user/local/etcd/ -s /sbin/nologin
    fi
    chown -R etcd:etcd /usr/local/etcd/
}

download_etcd
install_etcd
granted_etcd
