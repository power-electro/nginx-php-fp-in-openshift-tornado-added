#!/bin/bash 

PYTHON_VERSION="2.7.4"
PCRE_VERSION="8.35"
NGINX_VERSION="1.6.0"
MEMCACHED_VERSION="1.4.15"
ZLIB_VERSION="1.2.8"
#PHP_VERSION="5.5.9"
PHP_VERSION="5.4.27"

APC_VERSION="3.1.13"
libyaml_package="yaml-0.1.4"

if [[ "$HOME" = "" ]];then
	Current_DIR="$PWD"
	echo 'Current_DIR is:'
	echo $Current_DIR
else
	echo 'Current_DIR is home:'
	echo $Current_DIR
    Current_DIR="$HOME"
fi

if [[ "$OPENSHIFT_LOG_DIR" = "" ]];then
	#echo "$OPENSHIFT_LOG_DIR" > "$OPENSHIFT_HOMEDIR/.env/OPENSHIFT_DIY_LOG_DIR"
    if [ ! -d ${Current_DIR}/openshifts ]; then	        
	    mkdir  ${Current_DIR}/openshifts
    fi
	
    if [ ! -d ${Current_DIR}/openshifts/logs ]; then	
        mkdir ${Current_DIR}/openshifts/logs
    fi
	
	export OPENSHIFT_LOG_DIR="$Current_DIR/openshifts/logs/"
	echo 'OPENSHIFT_LOG_DIR is:'
	echo $OPENSHIFT_LOG_DIR
else
   echo "$OPENSHIFT_LOG_DIR Exists"
fi

if [[ "$OPENSHIFT_TMP_DIR" = "" ]]; then	
	#mkdir  ${Current_DIR}/openshifts
    if [ ! -d ${Current_DIR}/openshifts/tmp ]; then	
        mkdir ${Current_DIR}/openshifts/tmp
    fi
	export OPENSHIFT_TMP_DIR="$Current_DIR/openshifts/tmp/"
	echo 'OPENSHIFT_TMP_DIR2 is:'
	echo $OPENSHIFT_TMP_DIR
fi


if [ "$OPENSHIFT_HOMEDIR" = "" ]; then	
	if [ ! -d ${Current_DIR}/openshifts/app-root ]; then	
        mkdir ${Current_DIR}/openshifts/app-root
	fi
	
	if [ ! -d ${Current_DIR}/openshifts/app-root/runtime ]; then	
        mkdir ${Current_DIR}/openshifts/app-root/runtime
	fi
	
	
	export OPENSHIFT_HOMEDIR="$Current_DIR/openshifts/"
	echo 'OPENSHIFT_HOMEDIR is:'
	echo $OPENSHIFT_HOMEDIR
else
	echo 'OPENSHIFT_HOMEDIR exist:'
	echo $OPENSHIFT_HOMEDIR
fi

if [ "$OPENSHIFT_REPO_DIR" = "" ]; then	
	Current_DIR=$OPENSHIFT_HOMEDIR
fi
if [ "OPENSHIFT_REPO_DIR" = "" ]; then	
Current_DIR="$PWD"
fi
echo ${Current_DIR}
if [  -d ${Current_DIR}/.openshift/action_hooks/common ]; then	
    source ${Current_DIR}/.openshift/action_hooks/common
fi


if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv ]; then	
    mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv
fi
rm -rf $OPENSHIFT_TMP_DIR/*

if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin ]; then	
	cd $OPENSHIFT_TMP_DIR
	wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
	tar zxf nginx-${NGINX_VERSION}.tar.gz
	rm zxf nginx-${NGINX_VERSION}.tar.gz
	wget http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-${PCRE_VERSION}.tar.gz
	#wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
	tar zxf pcre-${PCRE_VERSION}.tar.gz
	rm pcre-${PCRE_VERSION}.tar.gz
	wget http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
	tar -zxf zlib-${ZLIB_VERSION}.tar.gz
	rm zlib-${ZLIB_VERSION}.tar.gz
    if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx ]; then
      mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx
    fi
	cd nginx-${NGINX_VERSION}	
	nohup sh -c "./configure\
	   --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx\
	   --with-pcre=$OPENSHIFT_TMP_DIR/pcre-${PCRE_VERSION}\
	   --with-zlib=$OPENSHIFT_TMP_DIR/zlib-${ZLIB_VERSION}\
	   --with-http_ssl_module\
	   --with-http_realip_module \
	   --with-http_addition_module \
	   --with-http_sub_module\
	   --with-http_dav_module \
	   --with-http_flv_module \
	   --with-http_mp4_module \
	   --with-http_gunzip_module\
	   --with-http_gzip_static_module \
	   --with-http_random_index_module \
	   --with-http_secure_link_module\
	   --with-http_stub_status_module \
	   --with-mail \
	   --with-mail_ssl_module \
	   --with-file-aio\
	   --with-ipv6	&& make && make install && make clean    " > $OPENSHIFT_LOG_DIR/Nginx_config.log 2>&1 & 
	bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/Nginx_config.log'
	
	#nohup sh -c "make && make install && make clean"  > $OPENSHIFT_LOG_DIR/nginx_install.log /dev/null 2>&1 &  
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/nginx_install.log
	#./configure --with-pcre=$OPENSHIFT_TMP_DIR/pcre-8.35 --prefix=$OPENSHIFT_DATA_DIR/nginx --with-http_realip_module
	#make &&	make install
fi


echo "INSTALL PHP"
if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/sbin ]; then
	cd $OPENSHIFT_TMP_DIR
	wget http://us1.php.net/distributions/php-${PHP_VERSION}.tar.gz
	tar zxf php-${PHP_VERSION}.tar.gz
	#rm  zxf php-${PHP_VERSION}.tar.gz
	cd php-${PHP_VERSION}
	#wget -c http://us.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror
	#tar -zxf mirror	
    if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION} ]; then
       mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}
    fi
	#cd php-${PHP_VERSION}
	
	nohup sh -c "./configure --with-mysql=mysqlnd\
        --with-mysqli=mysqlnd --with-xmlrpc --with-pdo-mysql=mysqlnd\
        --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}\
        --enable-fpm --with-zlib --enable-xml --enable-bcmath --with-curl --with-gd \
        --enable-zip --enable-mbstring --enable-sockets --enable-ftp"  > $OPENSHIFT_LOG_DIR/php_install_conf.log /dev/null 2>&1 &  
	bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/php_install_conf.log'
	nohup sh -c "make && make install && make clean"  > $OPENSHIFT_LOG_DIR/php_install.log 2>&1 &  
	bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/php_install.log'
	#./configure --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-5.4.27 --enable-fpm --with-zlib --enable-xml --enable-bcmath --with-curl --with-gd --enable-zip --enable-mbstring --enable-sockets --enable-ftp
#	make && make install
	cp  $OPENSHIFT_TMP_DIR/php-${PHP_VERSION}/php.ini-production ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/lib/php.ini
fi	
echo "Cleanup"
	cd $OPENSHIFT_TMP_DIR
	rm -rf *
PYTHON_CURRENT=`${OPENSHIFT_RUNTIME_DIR}/srv/python/bin/python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'`

#checked
if [ "$PYTHON_CURRENT" != "$PYTHON_VERSION" ]; then
	cd $OPENSHIFT_TMP_DIR
    if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv ]; then
	   mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv
    fi
	if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python ]; then
	   mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python
    fi
	wget http://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.bz2
	tar jxf Python-${PYTHON_VERSION}.tar.bz2
	rm -rf Python-${PYTHON_VERSION}.tar.bz2
	cd Python-${PYTHON_VERSION}
	
	#./configure --prefix=$OPENSHIFT_DATA_DIR
	nohup sh -c "./configure --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python && make install && make clean "   > $OPENSHIFT_LOG_DIR/pyhton_install.log 2>&1 &
	bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/pyhton_install.log'
	#nohup sh -c "make && make install && make clean"   >  $OPENSHIFT_LOG_DIR/pyhton_install.log 2>&1 &
	
	export "export path"
	export PATH=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin:$PATH
	nohup sh -c "export PATH=$OPENSHIFT_HOMEDIR/app-root/runtime/srv/python/bin:$PATH " > $OPENSHIFT_LOG_DIR/path_export2.log 2>&1 &
	echo '--Install Setuptools--'

	cd $OPENSHIFT_TMP_DIR
	
	#installing easy_install
	wget https://pypi.python.org/packages/source/s/setuptools/setuptools-1.1.6.tar.gz #md5=ee82ea53def4480191061997409d2996
	tar xzvf setuptools-1.1.6.tar.gz
	rm setuptools-1.1.6.tar.gz
	cd setuptools-1.1.6	
	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python setup.py install
	
	OPENSHIFT_RUNTIME_DIR=${OPENSHIFT_HOMEDIR}/app-root/runtime
	OPENSHIFT_REPO_DIR=${OPENSHIFT_HOMEDIR}/app-root/runtime/repo
	echo '---Install pip---'
	cd $OPENSHIFT_TMP_DIR
	curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python get-pip.py
	mkdir trash
	cd trash
	wget http://entrian.com/goto/goto-1.0.zip
	unzip goto-1.0.zip
	cd goto-1.0
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python setup.py install
	
	#memcached for python
	wget ftp://ftp.tummy.com/pub/python-memcached/python-memcached-latest.tar.gz
	tar -zxvf python-memcached-latest.tar.gz
	cd python-memcached-*	
	$OPENSHIFT_HOMEDIR/app-root/runtime/srv/python/bin/python setup.py install
	cd ../..
	rm -rf trash
	
	cd
	echo '---instlling tornado -----'
	nohup sh -c "\
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install tornado && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install reportlab && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install BeautifulSoup==3.2.1 && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install mechanize==0.2.5 && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pypdf==1.12 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install mongolog && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install django && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install hurry.filesize && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install reportlab==3.0 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pdfrw && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install webapp2 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install google && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install selenium && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install twill==0.9.1 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip  install lxml==3.2.3 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install cssselect==0.9.1 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install django-screamshot && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install img2pdf && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pdfminer && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pdfparanoia && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install youtube-dl && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install requesocks==0.10.8 && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install requests==2.4.1"> $OPENSHIFT_LOG_DIR/python_modules_install_1.log /dev/null 2>&1 &  
	#tail -f  $OPENSHIFT_LOG_DIR/python_modules_install_1.log
	#install pdf logo removal (pdfparanoia)
	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install uwsgi 
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install ipgetter 
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install cookielib
    ###############Proxy scraper ##########
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install ipwhois
    ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install netaddr	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install colorama
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install grab
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install dpath
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pygoogle
	
	
	nohup sh -c "\	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install uwsgi  && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install cookielib"> $OPENSHIFT_LOG_DIR/python_modules_install_1_1.log /dev/null 2>&1 &  
	#tail -f  $OPENSHIFT_LOG_DIR/python_modules_install_1_1.log
	#scholar pachage
	nohup sh -c "/
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install  google-scholar-scraper && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install springerdl && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install dbupload && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install  scrapy "> $OPENSHIFT_LOG_DIR/python_modules_install_2.log /dev/null 2>&1 &  
	#tail -f  $OPENSHIFT_LOG_DIR/python_modules_install_2.log
	#upload package
	#${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install dbupload
	#${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install  scrapy 
	
	nohup sh -c "/	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install click && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install wget && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install dropbox && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install PyDrive && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install mega.py && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install pymediafire && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install s3web"> $OPENSHIFT_LOG_DIR/python_modules_install_3.log /dev/null 2>&1 &  
	#tail -f  $OPENSHIFT_LOG_DIR/python_modules_install_3.log
	#upload to mega.co.nz 50 gig free
	#git clone https://github.com/TobiasTheViking/megaannex.git
	nohup sh -c "/${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install megacl"> $OPENSHIFT_LOG_DIR/python_modules_install_4.log /dev/null 2>&1 &  
	
	#upload ftp
	nohup sh -c "/
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install ftpsync &&\
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install Crypto && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install paramiko && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pycrypto && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install fabric"> $OPENSHIFT_LOG_DIR/python_modules_install_5.log /dev/null 2>&1 &  
	#tail -f  $OPENSHIFT_LOG_DIR/python_modules_install_5.log
	#install ghost webdirver
	#${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install 
	
	#install PyQt
	
	wget http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.9.6/PyQt-mac-gpl-4.9.6.tar.gz
	tar xzvf PyQt-mac-gpl-4.9.6.tar.gz
	cd PyQt-mac-gpl-4.9.6
	#install google-app
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install python-appengine #make working GAE code for any python
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install pyyaml
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install gae_installer
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install webob
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install Paste
	#must to install django <=1.1.4 pip install Django==1.1.4 
	#wget storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.13.zip
	#unzip google_appengine_1.9.13.zip
	#cd google_appengine
	
	nohup sh -c "/
	mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/google-app-sdk && \
	mv google_appengine ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/google_appengine && \
	export PATH=$PATH:${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/google_appengine && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install appengine"> $OPENSHIFT_LOG_DIR/python_modules_install_6.log /dev/null 2>&1 &  
	
	
	mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/gmp
	wget https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2
	tar -xvjpf gmp-6.0.0a.tar.bz2
	cd gmp-6.0.0a
	nohup sh -c "./configure --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/gmp && make && make check  &&make install && make clean "   > $OPENSHIFT_LOG_DIR/gmp_install.log 2>&1 &
	#tail -f $OPENSHIFT_LOG_DIR/gmp_install.log
	
	
	mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado
	#wget balabal
	#unzip bala
	

fi

# echo 'Make uwsgi '
	cd $OPENSHIFT_TMP_DIR
    if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python ]; then
      mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python
    fi
	
	wget http://projects.unbit.it/downloads/uwsgi-latest.tar.gz
	tar zxvf uwsgi-latest.tar.gz
	cd uwsgi-2.0.7

rm -rf $OPENSHIFT_TMP_DIR/*

	
if [[ `lsof -n -P | grep 8080` ]];then
	kill -9 `lsof -t -i :8080`
	lsof -n -P | grep 8080
fi
if [[ `lsof -n -P | grep 9000` ]];then
	kill -9 `lsof -t -i :9000`
	lsof -n -P | grep 9000
fi	
#---starting nginx ----
nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx -c  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf.default > $OPENSHIFT_LOG_DIR/nginx_run.log 2>&1 & 
#tail -f $OPENSHIFT_LOG_DIR/nginx_run.log
#nohup sh -c"${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/sbin/php-fpm -c  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/etc/php-fpm.conf"  > $OPENSHIFT_LOG_DIR/php_run.log 2>&1 & tail -f $OPENSHIFT_LOG_DIR/php_run.log
nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/sbin/php-fpm >  $OPENSHIFT_LOG_DIR/php_run.log 2>&1 &
#tail -f $OPENSHIFT_LOG_DIR/php_run.log
#---stoping nginx ----
nohup killall nginx > $OPENSHIFT_LOG_DIR/nginx_stop.log 2>&1 &
nohup killall php-fpm > $OPENSHIFT_LOG_DIR/php-fpm_stop.log 2>&1 &

#nohup sh -c  "./install-nginx-php.sh" > $OPENSHIFT_LOG_DIR/main_install.log /dev/null 2>&1  & tail -f $OPENSHIFT_LOG_DIR/main_install.log
bash -i -c 'tail -f $OPENSHIFT_DIY_LOG_DIR/Nginx_config.log'
#nohup sh -c "make && make install && make clean"  > $OPENSHIFT_LOG_DIR/nginx_install.log 2>&1 &  
        
nohup python ${DIR}/misc/ng_php_conf_hooks.py    > $OPENSHIFT_LOG_DIR/ng_php_conf_hooks.log 2>&1 &
nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx -c  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf > $OPENSHIFT_LOG_DIR/nginx_run.log 2>&1 &  bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/nginx_run.log'
nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/sbin/php-fpm  > $OPENSHIFT_LOG_DIR/php_run.log 2>&1 & bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/php_run.log'
#nohup sh -c  "./install-nginx-php.sh" > $OPENSHIFT_LOG_DIR/main_install.log 2>&1 &
#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/main_install.log'
