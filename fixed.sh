#!/bin/sh

./scripts/feeds clean -a
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds install -a
./scripts/feeds install -a

cp package/depend-package/golang feeds/packages/lang/ -r

mkdir -p package/gitfeed
git clone https://github.com/kenzok8/openwrt-packages package/gitfeed/kenzo
git clone https://github.com/sirpdboy/sirpdboy-package package/gitfeed/opentopd
git clone https://github.com/kenzok8/small package/gitfeed/small

