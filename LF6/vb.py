#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, subprocess
import sys, traceback
import crypt
# Passwort für den User vbox
password ="fbs"
print("UPDATE")
try:
    cmd1 = os.system("apt-get update > vb.log && sudo apt-get upgrade -y >> vb.log")
except:
    print("Update fehlgeschlagen!")
try:
    print("Installation von einigen Basisprogrammen")
    cmd1 = os.system("apt -y install screen emacs wget python-software-properties >> vb.log")
except:
    print("Installation fehlgeschlagen")
try:
    print("Repository hinzufügen")
    output = subprocess.check_output("lsb_release -sc", shell = True)
    lsb = str(output, 'utf-8').strip()    
    cmd1 = os.system("add-apt-repository 'deb http://download.virtualbox.org/virtualbox/debian "+lsb+" contrib'")
    cmd1 = os.system("add-apt-repository --remove 'deb-src http://download.virtualbox.org/virtualbox/debian "+lsb+" contrib'")
    # Änderung des Schlüssel für das Repository ab Ubuntu 16.04 (xenial)
    if lsb == "xenial":
        cmd1 = os.system("wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -")
    else:
        cmd1 = os.system("wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -")    
        cmd1 = os.system("apt-get update >> vb.log")
except:
    print("Repository hinzufügen fehlgeschlagen")
    print("Unexpected error:", sys.exc_info()[0])
    raise
try:
    print("Instalation VirtualBox")
    output = subprocess.check_output("uname -r", shell = True)
    Kernel = str(output, 'utf-8').strip()
    cmd1 = os.system("apt-get install -y linux-headers-"+Kernel)
    cmd1 = os.system("apt-get install -y build-essential virtualbox-5.0 dkms >> vb.log")
    cmd1 = os.system("apt-get install -y --allow-unauthenticated virtualbox-5.0 >> vb.log")
    cmd1 = os.system("apt-get install -y --allow-unauthenticated dkms >> vb.log")
    cmd1 = os.system ("wget http://download.virtualbox.org/virtualbox/5.0.16/Oracle_VM_VirtualBox_Extension_Pack-5.0.16.vbox-extpack >>vb.log")
    cmd1 = os.system("VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-5.0.16.vbox-extpack >>vb.log")
    encPass = crypt.crypt(password,"22")
    cmd1 = os.system("useradd -m -p "+encPass+" vbox -G vboxusers")
except:
    print("Installation von VirtualBox fehlgeschlagen")
try:
    print("Installation von phpVirtualBox")
    print("Vorbereitung ...")
    # Datei /etc/default/virtualbox anlegen und User eintragen
    datei = open("/etc/default/virtualbox", "w")
    datei.write("VBOXWEB_USER=vbox")
    datei.close()
except:
    print("Installation von phpVirtualBox fehlgeschlagen")
try:
    print("Web-Server installieren ..")
    if lsb == "xenial":
        cmd1 = os.system("apt-get -y install php7.0 php7.0-mysql apache2 apache2-utils >> vb.log")
# Neues Modul ab Ubuntu 16.04: https://sourceforge.net/p/phpvirtualbox/discussion/help/thread/ae25b8e7/
        cmd1 = os.system("apt-get -y install php7.0-xml")
    else:
        cmd1 = os.system("apt-get install php5 php5-mysql apache2 apache2-utils vb.log")
    cmd1 = os.system("wget 'http://sourceforge.net/projects/phpvirtualbox/files/latest/download' --content-disposition")
    cmd1 = os.system ("apt-get -y install unzip >> vb.log")
    cmd1 = os.system("unzip -o phpvirtualbox-5.0-5.zip -d /var/www/html >> vb.log")
    cmd1 = os.system("ln -s /var/www/html/phpvirtualbox-5.0-5 /var/www/html/phpvirtualbox")
    cmd1 = os.system("chown -R www-data.www-data /var/www")
    cmd1 = os.system("service vboxweb-service stop")
    cmd1 = os.system("/sbin/rcvboxdrv setup")
    cmd1 = os.system("service vboxweb-service start")
    cmd1 = os.system("cp /var/www/html/phpvirtualbox/config.php-example /var/www/html/phpvirtualbox/config.php")
#    cmd1 = os.system("sed s/\'pass\'/\'fbs\'/ /var/www/html/phpvirtualbox/config.php > /var/www/html/phpvirtualbox/config.php")
#Datei einlesen
    f = open('/var/www/html/phpvirtualbox/config.php','r')
    filedata = f.read()
    f.close()

    newdata = filedata.replace("'pass'","'fbs'")

    f = open('/var/www/html/phpvirtualbox/config.php','w')
    f.write(newdata)
    f.close()
except:
    print("Web-Server fehlgeschlagen")