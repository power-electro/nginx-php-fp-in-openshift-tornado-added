#!/bin/bash 

PYTHON_VERSION="2.7.4"
PCRE_VERSION="8.35"
#NGINX_VERSION="1.6.0"
NGINX_VERSION="1.10.1"
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
	#git clone https://github.com/cep21/healthcheck_nginx_upstreams.git
	git clone https://github.com/gnosek/nginx-upstream-fair.git
	
	wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
	tar zxf nginx-${NGINX_VERSION}.tar.gz
	rm  nginx-${NGINX_VERSION}.tar.gz
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
	./configure\
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
	   --with-ipv6\
	   --add-module=$OPENSHIFT_TMP_DIR/nginx-upstream-fair
	   #--add-module=$OPENSHIFT_TMP_DIR/healthcheck_nginx_upstreams\
	   make && make install && make clean   # " > $OPENSHIFT_LOG_DIR/Nginx_config.log 2>&1 & 
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/Nginx_config.log'
	
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
	
	./configure --with-mysql=mysqlnd\
        --with-mysqli=mysqlnd --with-xmlrpc --with-pdo-mysql=mysqlnd\
        --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}\
        --enable-fpm --with-zlib --enable-xml --enable-bcmath --with-curl --with-gd \
        --enable-zip --enable-mbstring --enable-sockets --enable-ftp #"  > $OPENSHIFT_LOG_DIR/php_install_conf.log /dev/null 2>&1 &  
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/php_install_conf.log'
	make && make install && make clean #"  > $OPENSHIFT_LOG_DIR/php_install.log 2>&1 &  
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/php_install.log'
	#./configure --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-5.4.27 --enable-fpm --with-zlib --enable-xml --enable-bcmath --with-curl --with-gd --enable-zip --enable-mbstring --enable-sockets --enable-ftp
#	make && make install
	cp  $OPENSHIFT_TMP_DIR/php-${PHP_VERSION}/php.ini-production ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/lib/php.ini
fi	
echo "Cleanup"
cd $OPENSHIFT_TMP_DIR
rm -rf *
#PYTHON_CURRENT=`${OPENSHIFT_RUNTIME_DIR}/srv/python/bin/python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'`

#checked
#if [ "$PYTHON_CURRENT" != "$PYTHON_VERSION" ]; then
if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin ]; then
	cd $OPENSHIFT_TMP_DIR
	
    if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv ]; then
	   mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv
    fi
	if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python ]; then
	   mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python
    fi
	rm Python-${PYTHON_VERSION}.tar.bz2
	wget http://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.bz2
	tar jxf Python-${PYTHON_VERSION}.tar.bz2
	#rm -rf Python-${PYTHON_VERSION}.tar.bz2
	cd Python-${PYTHON_VERSION}
	
	#./configure --prefix=$OPENSHIFT_DATA_DIR
	./configure --prefix=${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python && make install && make clean #"   > $OPENSHIFT_LOG_DIR/pyhton_install.log 2>&1 &
	#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/pyhton_install.log'
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
	#nohup sh -c "\
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pyPdf && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pypdftk && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install robobrowser 
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install httplib2 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install hurry.filesize && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install tornado==4.2.1 && \
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
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install lxml==3.2.3 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install cssselect==0.9.1 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install django-screamshot && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install img2pdf && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pdfminer && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pdfparanoia && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install youtube-dl && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install requesocks==0.10.8 && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install requests==2.4.1 #"> $OPENSHIFT_LOG_DIR/python_modules_install_1.log /dev/null 2>&1 &  
	#tail -f  $OPENSHIFT_LOG_DIR/python_modules_install_1.log
	
	
	nohup sh -c "\
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pyPdf && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pypdftk && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install robobrowser && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install httplib2 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install hurry.filesize && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install tornado==4.2.1 && \
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
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install lxml==3.2.3 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install cssselect==0.9.1 && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install django-screamshot && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install img2pdf && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pdfminer && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install pdfparanoia && \
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install youtube-dl && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install requesocks==0.10.8 && \	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install requests==2.4.1 "> $OPENSHIFT_LOG_DIR/python_modules_install_1.log /dev/null 2>&1 &  
	#tail -f  $OPENSHIFT_LOG_DIR/python_modules_install_1.log
	
	
	#install pdf logo removal (pdfparanoia)
	
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/easy_install lxml==3.2.3 
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
	cd $OPENSHIFT_TMP_DIR
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
	
	#nohup sh -c "/
	#mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/google-app-sdk && \
	#mv google_appengine ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/google_appengine && \
	#export PATH=$PATH:${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/google_appengine && \
	#${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/pip install appengine"> $OPENSHIFT_LOG_DIR/python_modules_install_6.log /dev/null 2>&1 &  
	
	
	mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/gmp
	cd $OPENSHIFT_TMP_DIR
	wget https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2
	tar -xvjpf gmp-6.0.0a.tar.bz2
	cd gmp-6.0.0*
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
	
nohup sh -c " wget http://projects.unbit.it/downloads/uwsgi-latest.tar.gz &	tar zxvf uwsgi-latest.tar.gz & cd uwsgi-2.0.7"  > $OPENSHIFT_LOG_DIR/uwsgi_install.log 2>&1 &



if [ ! -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/cpdf ]; then
	echo "installing cpdf"
	mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/cpdf
	cd  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/cpdf
	git clone https://github.com/coherentgraphics/cpdf-binaries.git
	mv cpdf-binaries/Linux-Intel-64bit/* .
	rm -rf cpdf-binaries
fi

rm -rf $OPENSHIFT_TMP_DIR/*

	
#---starting nginx ----
nohup sh -c "${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx -c  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf.default " > $OPENSHIFT_LOG_DIR/nginx_run.log 2>&1 & 
#tail -f $OPENSHIFT_LOG_DIR/nginx_run.log
#nohup sh -c"${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/sbin/php-fpm -c  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/etc/php-fpm.conf"  > $OPENSHIFT_LOG_DIR/php_run.log 2>&1 & tail -f $OPENSHIFT_LOG_DIR/php_run.log
nohup sh -c "${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/sbin/php-fpm" >  $OPENSHIFT_LOG_DIR/php_run.log 2>&1 &
#tail -f $OPENSHIFT_LOG_DIR/php_run.log
#---stoping nginx ----
nohup sh -c "killall nginx " > $OPENSHIFT_LOG_DIR/nginx_stop.log 2>&1 &
nohup sh -c "killall php-fpm "> $OPENSHIFT_LOG_DIR/php-fpm_stop.log 2>&1 &

#nohup sh -c  "./install-nginx-php.sh" > $OPENSHIFT_LOG_DIR/main_install.log /dev/null 2>&1  & tail -f $OPENSHIFT_LOG_DIR/main_install.log
#bash -i -c 'tail -f $OPENSHIFT_DIY_LOG_DIR/Nginx_config.log'
#nohup sh -c "make && make install && make clean"  > $OPENSHIFT_LOG_DIR/nginx_install.log 2>&1 &  
        
nohup python ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/nginx-php-fp-in-openshift-tornado-added/misc/ng_php_conf_hooks.py    > $OPENSHIFT_LOG_DIR/ng_php_conf_hooks.log 2>&1 &
nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx -c  ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf > $OPENSHIFT_LOG_DIR/nginx_run.log 2>&1 & 
#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/nginx_run.log'
nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/php-${PHP_VERSION}/sbin/php-fpm  > $OPENSHIFT_LOG_DIR/php_run.log 2>&1 & 
#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/php_run.log'

#rm -rf ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/cron/*
cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/nginx-php-fp-in-openshift-tornado-added/.openshift/cron
chmod 755 -R .

cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/cron
cp ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/nginx-php-fp-in-openshift-tornado-added/.openshift/cron/daily/cron  ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/cron/daily/cron
cp  -rf ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/nginx-php-fp-in-openshift-tornado-added/.openshift/cron/. ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/cron/
#cp  -rf ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/nginx-php-fp-in-openshift-tornado-added/.openshift/cron/daily/cron  ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/cron/daily/cron
cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/cron
chmod 755 -R ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/cron/daily/cron
mkdir daily 
mkdir hourly 
mkdir minutely 
mkdir monthly 
mkdir weekly
chmod 755 -R .
echo "ls from dial cron folder"
cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/cron/daily && ls

cd $OPENSHIFT_TMP_DIR


cp ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/nginx-php-fp-in-openshift-tornado-added/.openshift/action_hooks/stop ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/action_hooks/stop
cp ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/nginx-php-fp-in-openshift-tornado-added/.openshift/action_hooks/start ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/action_hooks/start
chmod 755 ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/action_hooks/start
chmod 755 ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/.openshift/action_hooks/stop
if [ -d ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin ]; then

	mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3
	rm  -rf ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/*
	cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3
	git clone  https://elasa:ss123456@gitlab.com/elasa/ieee2.git
	mv i*/al*/* .


	## Adding DNS in Free-papers.elasa.ir  site list ######
	cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo
	rm -rf ${OPENSHIFT_HOMEDIR}app-root/runtime/repo/free-papers_elasa_ir_site-list
	git clone https://github.com/power-electro/free-papers_elasa_ir_site-list.git
	#$File="${OPENSHIFT_HOMEDIR}app-root/runtime/repo/free-papers_elasa_ir_site-list/openshift_freepapers_site_list.txt"
	cd ${OPENSHIFT_HOMEDIR}app-root/runtime/repo/free-papers_elasa_ir_site-list/
	#if grep -q $OPENSHIFT_GEAR_DNS "$File"; then
	if grep -q $OPENSHIFT_GEAR_DNS "openshift_freepapers_site_list.txt"; then
	   echo $OPENSHIFT_GEAR_DNS "is in file"
	else  
       echo $OPENSHIFT_GEAR_DNS  >> openshift_freepapers_site_list.txt
       echo $OPENSHIFT_GEAR_DNS "added in file"
       git commit -a  -m "$OPENSHIFT_GEAR_DNS added" 
       git config remote.origin.url https://soheilpaper:ss123456@github.com/power-electro/free-papers_elasa_ir_site-list.git
	   #git remote add origin https://soheilpaper:ss123456@github.com/power-electro/free-papers_elasa_ir_site-list.git
	   git push -u origin master
	fi


	#${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/save_source.py
	mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/www
	
	kill -9 `lsof -t -i :15001`
	kill -9 `lsof -t -i :15002`
	kill -9 `lsof -t -i :15003`
	kill -9 `lsof -t -i :8080`
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx -c ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf " > ${OPENSHIFT_LOG_DIR}/server-template.log 2>&1 &
	${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/tornado-get.py  --port '15001' --root '${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3' --wtdir '/static'
	
	
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/tornado-get.py  --port '15001' --root '${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3' --wtdir '/static'" > ${OPENSHIFT_LOG_DIR}/tornado1.log /dev/null 2>&1 &
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/tornado-get.py  --port '15002' --root '${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3' --wtdir '/static'" > ${OPENSHIFT_LOG_DIR}/tornado2.log /dev/null 2>&1 &
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/tornado-get.py  --port '15003' --root '${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3' --wtdir '/static'" > ${OPENSHIFT_LOG_DIR}/tornado3.log /dev/null 2>&1 &
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx -c ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf " > ${OPENSHIFT_LOG_DIR}/server-template.log 2>&1 &
	
	kill -9 `lsof -t -i :15001`
	kill -9 `lsof -t -i :15002`
	kill -9 `lsof -t -i :15003`
	kill -9 `lsof -t -i :8080`
	
	mkdir ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/www
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/tornado-get.py  --port '15001' --root '${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3' --wtdir '/static'" > ${OPENSHIFT_LOG_DIR}/tornado1.log /dev/null 2>&1 &
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/tornado-get.py  --port '15002' --root '${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3' --wtdir '/static'" > ${OPENSHIFT_LOG_DIR}/tornado2.log /dev/null 2>&1 &
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3/tornado-get.py  --port '15003' --root '${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/tornado3' --wtdir '/static'" > ${OPENSHIFT_LOG_DIR}/tornado3.log /dev/null 2>&1 &
	nohup sh -c " ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx -c ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/conf/nginx.conf " > ${OPENSHIFT_LOG_DIR}/server-template.log 2>&1 &

fi
#nohup sh -c  "./install-nginx-php.sh" > $OPENSHIFT_LOG_DIR/main_install.log 2>&1 &
#bash -i -c 'tail -f $OPENSHIFT_LOG_DIR/main_install.log'

