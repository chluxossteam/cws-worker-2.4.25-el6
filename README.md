## 1.2 Release Note
CWS is open source project based on apache httpd web server same as ews serise. 

Feature  
- Easy install with installation script
- Embedded Pcre-8.39 for apache 
- Preinstall apache tomcat connector(mod_jk 1.2.42)
- Preinstall almost apache module 
- It can build 3rd party's apache extension module with apxs  

## Requirement 
OS : RedHat Enterprise Linux6, CentOS6  
SELINUX : disable 

## Included Packages
 - httpd-2.4.25 
 - apr-1.5.2
 - apr-util-1.5.4
 - pcre-8.39
 - tomcat-connectors-1.2.42(mod_jk) 

## Installation 
 - Download cws-worker-2.4.25 or clone from git
 - Decompress cws-worker-2.4.25.zip to target directory
 - execute .install.sh (hidden file by . (dot) 
 - choose log directory (enter the path/directory name for log storage) 
 - enter the name of apache user / group
 - execute ${INSTALLED_CWS}/sbin/apachectl start


## Document Root
 - ${INSTALL_PATH}/htdocs 

## REFERENCE
http://httpd.apache.org/docs/2.4/
