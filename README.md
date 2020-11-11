# NGINX-ModSecurity

ModSecurity adalah Web Application Firewall (WAF), yang awalnya dirancang sebagai modul untuk Apache HTTP Server. ModSecurity digunakan untuk melindungi situs web dari serangan jahat dan ancaman keamanan, seperti SQL injection (SQLi), Local File Inclusion (LFI), dan Cross‑Site Scripting (XSS) dan masih banyak lagi.

## Langkah Install

Tutorial installasi ini menggunakan Debian 10 dan CentOS 8. Kemungkinan langkah - langkahnya akan sama dengan; Ubuntu 15.04-versi terbaru, Debian 8-versi terbaru, CentOS 7-versi terbaru.

### Install NGINX

Langkah pertama adalah menginstal NGINX. Banyak sekali cara untuk menginstall NGINX.

#### Debian/Ubuntu

```shell
$ apt-get install nginx
```

#### CentOS/Redhat

```shell
$ yum install epel-release
$ yum install nginx
$ yumdownloader --source nginx
```

### Install Paket Yang Dibutuhkan

Selanjutnya menginstall paket yang diperlukan untuk menyelesaikan langkah-langkah selanjutnya dalam tutorial ini.

#### Debian/Ubuntu

```shell
$ apt-get install git wget g++ flex bison curl doxygen libyajl-dev libgeoip-dev libtool dh-autoreconf libcurl4-gnutls-dev libxml2 libxml2-dev libxslt1-dev libgd-dev libpcre++-dev
```

#### CentOS/Redhat

```shell
$ yum install yum-utils make automake autoconf git rpm-build perl-devel gperftools-devel openssl-devel pcre-devel zlib-devel GeoIP-devel gd-devel libxslt-devel perl-ExtUtils-Embed.noarch gcc gcc-c++ libtool wget -y
```

### Download dan Compile Source Code ModSecurity 3.0

Dengan menginstal kebutuhan paket yang diperlukan, langkah selanjutnya adalah mengompile ModSecurity sebagai dynamic modul NGINX. Dalam arsitektur modular baru ModSecurity 3.0, libmodsecurity adalah komponen inti yang mencakup semua aturan dan fungsionalitas. Komponen utama kedua dalam arsitektur adalah konektor yang menghubungkan libmodsecurity ke server web yang menjalankannya.  

#### Debian/Ubuntu dan CentOS/Redhat

1.  Clone repository GitHub:

```shell
$ cd /opt/
$ git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
```

2.  Pindah ke directory ModSecurity dan compile source codenya:

```shell
$ cd ModSecurity/
$ git submodule init
$ git submodule update
$ ./build.sh
$ ./configure --disable-dependency-tracking
$ make -j2
$ make install
$ cd ../
```

### Download Konektor NGINX untuk ModSecurity dan Compile sebagai Dynamic Modul

Kompilasi konektor ModSecurity untuk NGINX sebagai modul dinamis untuk NGINX.

#### Debian/Ubuntu dan CentOS/Redhat

1.  Clone repository GitHub:

```shell
$ git clone https://github.com/SpiderLabs/ModSecurity-nginx.git
```

2.  Download source code NGINX untuk compile dynamic modul.

```shell
$ wget https://raw.githubusercontent.com/XCyberusX/NGINX-ModSecurity/main/nginx-version.sh
$ source nginx-version.sh
```

3.  Compile dynamic modul and copy file modul ke directory standar untuk modul NGINX.

```shell
$ nginx -V 2>&1 | grep 'configure arguments' | sed "s#configure arguments:#./configure --add-dynamic-module=../ModSecurity-nginx #g" |bash
$ make modules
  #if error see below.
  https://trac.nginx.org/nginx/changeset/9e25a5380a21240cdb66646f1e20ef7247b646a1/nginx
$ cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/ /usr/share/nginx/modules/
$ cd ~
```

## Load Konektor Dynamic Modul ModSecurity

Tambahkan direktive load_module ke **/etc/nginx/nginx.conf**:

```shell
$ nano /etc/nginx/nginx.conf
  load_module modules/ngx_http_modsecurity_module.so;
```

## Konfigurasi dan Testing ModSecurity

Pertama, copy contoh file konfigurasi ModSecurity dari direktori GitHub ke direktori konfigurasi NGINX.

```shell
$ mkdir /etc/nginx/modsec
$ cp /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
$ cp /opt/ModSecurity/unicode.mapping /etc/nginx/modsec
```

Download ModSecurity Core Rule dari repository GitHub. Rename filenya.

```shell
$ git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /etc/nginx/modsec/owasp-crs
$ mv /etc/nginx/modsec/owasp-crs/crs-setup.conf.example /etc/nginx/modsec/owasp-crs/crs-setup.conf
```

Lalu edit **/etc/nginx/secmod/modsecurity.conf**. Edit line **SecRuleEngine** dan tambahkan baris berikut di akhir file:

```shell
  .........
  SecRuleEngine On
  .................
  #Tambahkan line berikut
  Include owasp-crs/crs-setup.conf
  Include owasp-crs/rules/*.conf
```

Tambahkan directives modsecurity dan modsecurity_rules_file ke konfigurasi NGINX atau ke konfiguras virtual host untuk mengaktifkan ModSecurity:

```shell
server {
  .....
  modsecurity on;
  modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;
  .........
}
```

Cek konfigurasi NGINX. Jika tidak ada masalah, restart service NGINX.

```shell
$ nginx -t
$ service nginx restart
```

Untuk testing nya dengan akses http://localhost/index.html?exec=/bin/bash atau http://localhost/?q="><script>alert(1)</script>"

```shell
$ curl http://localhost/index.html?exec=/bin/bash
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.14.2</center>
</body>
</html>

$ curl http://localhost/?q="><script>alert(1)</script>"
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.14.2</center>
</body>
</html>
```

Jika ingin melihat log penyerangannya dapat dilihat pada:
```shell
$ tail -f /var/log/modsec_audit.log /var/log/nginx/error.log
```
