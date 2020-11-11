#!/usr/bin/env bash

version=$(nginx -v 2>&1 | cut -d '/' -f 2)
wget 'http://nginx.org/download/nginx-'$version'.tar.gz'
tar zxvf 'nginx-'$version'.tar.gz'
cd 'nginx-'$version
