#!/usr/bin/env bash

version=$(script -c 'nginx -v' | grep 'nginx' | awk '{print $3}' | cut -d '/' -f 2 | tr -d '\r')
wget 'http://nginx.org/download/nginx-'$version'.tar.gz'
rm -f typescript
tar zxvf 'nginx-'$version'.tar.gz'
cd 'nginx-'$version
