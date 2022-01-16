#!/bin/sh
rm feeds/packages/net/xtables-addons -r
rm feeds/packages/utils/runc -r
rm feeds/packages/lang/golang -r
cp packages/github/golang feeds/packages/lang/ -r
rm -rf feeds/packages/utils/containerd
rm -rf feeds/packages/utils/libnetwork
rm -rf  feeds/node/node-cylon-i2c 
rm -rf feeds/node/node-cylon-gpio

mkdir -p package/gitfeed
git clone https://github.com/kenzok8/openwrt-packages package/gitfeed/kenzo
git clone https://github.com/sirpdboy/sirpdboy-package package/gitfeed/opentopd
git clone https://github.com/kenzok8/small package/gitfeed/small

