#!/bin/sh

umask 077
currentDir=`pwd` 
APACHE_USER="daemon" 

VERSION=`cat version`
_front()
{
    TITLE="CHLUX APACHE INSTALLER"
    clear
    eval printf %.0s\# '{1..'${COLUMNS:-$(tput cols)}'}'; echo    
    echo "" 
    printf "%*s\n" $(((${#TITLE}+$(tput cols))/2)) "$TITLE"
    echo  " Version : ${VERSION} (CWS-WORKER-2.4.25)" 
    echo  " Author  : Chlux Co,Ltd."
    echo  " Release : 01. Jun. 2017" 
    echo  " Package : pcre-0.8, apache-httpd-2.4.25, apr-1.5.2, apr-util-1.5.4 , mod_jk-1.2.42" 
    echo  " Requirement : Root Permission (Installation)"
    echo  "             : Root Permission (Running)" 
    echo  ""
    eval printf %.0s\# '{1..'${COLUMNS:-$(tput cols)}'}'; echo  

}

_footer()
{ 
    eval printf %.0s\# '{1..'${COLUMNS:-$(tput cols)}'}'; echo      
    echo " Install Result " 
    echo " Apache Directory : $1"
    echo " Apache User      : $2" 
    echo " Apache Group     : $3" 
    echo " Apache Script    : " `ls -l /etc/init.d/httpd`
    eval printf %.0s\# '{1..'${COLUMNS:-$(tput cols)}'}'; echo    
} 

FQDN=`hostname`
if [ "${FQDN}" = "x" ]; then
        FQDN=localhost.localdomain
fi


## CALL basic information for this script
_checkuser()
{
    # Setup User / group for Apache 
    echo "  2. Check user for web server " 
    echo -n "  - Webserver user (default : ${APACHE_USER}):" 
    read APACHE_USER 
    APACHE_GROUP=${APACHE_USER}
    echo -n "  - Webserver group (default : ${APACHE_GROUP}):"
    read APACHE_GROUP

    if [ -z ${APACHE_USER}  ]; then 
	    APACHE_USER="daemon"
    fi 

    if [ -z ${APACHE_GROUP} ]; then
        APACHE_GROUP=${APACHE_USER} 
    fi

    #check user
    ret=false
    getent passwd ${APACHE_USER} >/dev/null 2&>1 && ret=true
    #echo ${ret}

    if ${ret}; then 
        echo "  - UID/GID (${APACHE_USER}/${APACHE_GROUP}) is already exists, Will use this UID."
    else  
        #groupadd ${APACHE_GROUP} > /dev/null 2&>1  
        if [ ! $(getent group ${APACHE_GROUP}) ]; then  
            groupadd ${APACHE_GROUP}
        fi
        GROUP_SW="-g ${APACHE_GROUP}"
        useradd ${GROUP_SW} -M -r -d ${currentDir} ${APACHE_USER} -s /sbin/nologin > /dev/null 
        echo "  - Create USER/GROUP for Apache (${APACHE_USER}/${APACHE_GROUP})"
    fi
}

_startinstall()
{
    echo "  3. Start install"
    #cp ${currentDir}/conf/original/httpd.conf.dist ${currentDir}/conf/httpd.conf 

    #sed -i -e "s:User daemon:User ${APACHE_USER}:g" -e "s:Group daemon:Group ${APACHE_GROUP}:g" -e "s: modules/: ${currentDir}/modules/:g"   conf/httpd.conf
    #sed -i -e "s:User daemon:User ${APACHE_USER}:g" -e "s:Group daemon:Group ${APACHE_GROUP}:g" conf/httpd.conf
cat > .tmppostinstallfile << EOF
    # the option for httpd command
OPTIONS=" -f ${currentDir}/conf/httpd.conf -E ${currentDir}/logs/httpd.log" 
# the Library path 
export LD_LIBRARY_PATH=${currentDir}/lib:${currentDir}/pcre/lib
export PATH=${PATH}:${currentDir}/pcre/bin
EOF

	mv ${currentDir}/sbin/apachectl ${currentDir}/sbin/apachectl.cwssave
	cp ${currentDir}/sbin/apachectl.dist ${currentDir}/sbin/apachectl 
	#chmod 700 ${currentDir}/sbin/apachectl
	#sed -i -e "s:HTTPD='./httpd':HTTPD='${currentDir}/sbin/httpd':g" -e "/HTTPD=/r .tmppostinstallfile" sbin/apachectl
	#rm -f .tmppostinstallfile  

	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/disproxy
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/dismpm
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/dismodjk
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/enproxy
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/enmpm
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/enmodjk
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/apr-1-config
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/apu-1-config
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/apxs
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./build/config.nice
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./build/config_vars.mk
	sed -i -e "s:/tmp/httpd-2.4.25/srclib:${currentDir}:g" ./build/config_vars.mk 
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./build/apr_rules.mk   

	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/original/httpd.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/original/extra/httpd-manual.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/original/extra/httpd-dav.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/original/extra/httpd-ssl.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/original/extra/httpd-vhosts.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/original/extra/httpd-multilang-errordoc.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/original/extra/httpd-modjk.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/original/extra/httpd-autoindex.conf

	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/httpd.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/extra/httpd-manual.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/extra/httpd-dav.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/extra/httpd-ssl.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/extra/httpd-vhosts.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/extra/httpd-multilang-errordoc.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/extra/httpd-modjk.conf
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./conf/extra/httpd-autoindex.conf
	
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./include/ap_config_auto.h
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./include/ap_config_layout.h 

	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./lib/libexpat.la 
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./lib/pkgconfig/apr-1.pc
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./lib/pkgconfig/apr-util-1.pc
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./lib/libapr-1.la
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./lib/libaprutil-1.la 

	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/lib/libpcreposix.la
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/lib/libpcre32.la
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/lib/libpcre16.la
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/lib/libpcre.la
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/lib/pkgconfig/libpcre16.pc
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/lib/pkgconfig/libpcre32.pc
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/lib/pkgconfig/libpcre.pc
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/lib/pkgconfig/libpcreposix.pc
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./pcre/bin/pcre-config 
	
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/enmpm
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/dismpm
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/enmodjk
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/dismodjk
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/enproxy
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./bin/disproxy
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./sbin/envvars
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./sbin/envvars-std
	sed -i -e "s:/opt/cws-worker-2.4.25:${currentDir}:g" ./sbin/apachectl
	sed -i -e "s:HTTPD='./httpd':HTTPD='${currentDir}/sbin/httpd':g" -e "/HTTPD=/r .tmppostinstallfile" sbin/apachectl
	rm -f .tmppostinstallfile  
	chmod 700 ${currentDir}/sbin/apachectl
    sed -i -e "s:User daemon:User ${APACHE_USER}:g" -e "s:Group daemon:Group ${APACHE_GROUP}:g" -e "s: modules/: ${currentDir}/modules/:g"   conf/httpd.conf
	
	_makeExtra
} 

_makesymlink() 
{
    echo "  4. Registering webserver service file (/etc/init.d/httpd)" 
    if [ -x '/etc/init.d/httpd.cwasbackup' ]; then 
        rm -rf /etc/init.d/httpd.cwasbackup
    fi
    if [ -x '/etc/init.d/httpd' ]; then
        echo "  - Backup /etc/init.d/httpd to /etc/init.d/httpd.cwasbackup"
	mv /etc/init.d/httpd /etc/init.d/httpd.cwasbackup
    fi 
    ln -s ${currentDir}/sbin/apachectl /etc/init.d/httpd
}

_changePermission()
{ 
    echo "  5. Change to onwership"
    echo "  - Change ownership of ${currentDir} to ${APACHE_USER}\/${APACHE_GROUP}"
    chown -R ${APACHE_USER}:${APACHE_GROUP} $currentDir
    find ${currentDir}/htdocs -type d -exec chmod g+rx {} +
    find ${currentDir}/htdocs -type f -exec chmod g+r {} + 
    find ${currentDir}/htdocs -type d -exec chmod g+s {} + 
	# should add sticy bit it onwer is not root  
	#
 	# 
    chmod -R o-rwx ${currentDir}/htdocs/ 
    echo "  -------------------------"
    echo "  -- Finish installation --"  
    echo "  -------------------------"
}

_makeExtra()
{
    #cp ${currentDir}/conf/extra.dist/*.conf ${currentDir}/conf/extra/

    sed -i -e "s:/var:${currentDir}:g" conf/extra/*.conf
}

_makeLogs()
{ 
    echo "  1. Setup log directory" 
    echo "  -------------------------------"
    curLogDir=${currentDir}"/logs"
    LOGDIR=${currentDir}"/logs" 
    if [ -d ${curLogDir} ]; then 
        echo "Please delete or unlink current log directory : ${curLogDir}"
        exit
    fi
    #echo "  -- Setup log dir\e[0m"
    echo -n "   Log directory path : (default : ${curLogDir}):"  
    read NEWPATH

    if [ ${NEWPATH} ]; then   
        if [ ${curLogDir} != ${NEWPATH} ]; then     
            echo "Create log directory (${NEWPATH})"
            mkdir -p ${NEWPATH}	 
            ln -s ${NEWPATH} logs  
            LOGDIR=${NEWPATH}
        else 
            echo " Exit installation"	
        fi  
    else 
        mkdir -p ${curLogDir} 
        LOGDIR=${curLogDir}
    fi  
} 
_checkenv() 
{    
    echo "  Owner     : "${APACHE_USER} 
    echo "Owner     : "${APACHE_USER} >> install.log 
	echo "  Group     : "${APACHE_GROUP} 
	echo "Group     : "${APACHE_GROUP}  >> install.log 
    echo "  Log Path  : "${LOGDIR}
    echo "Log Path  : "${LOGDIR} >> install.log
    echo "  Glibc     : "`rpm -qa | grep glibc` 
    echo "Glibc     : "`rpm -qa | grep glibc`  >> install.log
 	echo "  Apache    : "`${currentDir}/sbin/apachectl -v`
 	echo "Apache    : "`${currentDir}/sbin/apachectl -v` >> install.log
    echo "  APR       : "`${currentDir}/bin/apr-1-config --version` 
    echo "APR       : "`${currentDir}/bin/apr-1-config --version` >> install.log
    echo "  APR Util  : "`${currentDir}/bin/apu-1-config --version` 
    echo "APR Util  : "`${currentDir}/bin/apu-1-config --version` >> install.log 
	echo "  PCRE      : "`${currentDir}/pcre/bin/pcre-config --version`
	echo "PCRE      : "`${currentDir}/pcre/bin/pcre-config --version` >> install.log
} 
_createLdPath()
{ 
	echo "${currentDir}/lib" > /etc/ld.so.conf.d/cws-apache.conf
	echo "${currentDir}/prec/lib" >> /etc/ld.so.conf.d/cws-apache.conf 
	ldconfig
}
_front 
_makeLogs
_checkuser 
_startinstall 
#_makeExtra 
_makesymlink 
_changePermission  
_createLdPath
_checkenv
