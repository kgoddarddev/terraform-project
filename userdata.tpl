#!/bin/bash
#Install LAMP
#update first
sudo apt-get update
echo 'Installing Apache Web Server'
apt --assume-yes install apache2 -y  >> /var/log/imagine.log
##########################################
#Apache install complete 
echo 'Apache Web Server is installed' >> /var/log/imagine.log
##########################################
echo 'Installing MySQL' >> /var/log/imagine.log
##########################################
##########################################
sudo apt --assume-yes install mysql-server >> /var/log/imagine.log
##########################################
##########################################
echo 'MySQL db installed starting service' >> /var/log/imagine.log
##########################################
#starting the mysql service
sudo systemctl start mysql.service >> /var/log/imagine.log
##########################################
#On to PHP install
echo 'Installing php and its modules' >> /var/log/imagine.log
##########################################
##########################################
sudo apt --assume-yes install php-pear php-dev  php-curl php-gd php-mysql  php-xml libapache2-mod-php -y  unzip >> /var/log/imagine.log
##########################################
##########################################
echo 'php and its modules installed' >> /var/log/imagine.log
##########################################
##########################################
echo 'Starting the services' >> /var/log/imagine.log
##########################################
systemctl restart apache2 >> /var/log/imagine.log
##########################################
systemctl restart mysql >> /var/log/imagine.log
echo 'Enabling the services' >> /var/log/imagine.log
##########################################
systemctl enable apache2 >> /var/log/imagine.log
##########################################
systemctl enable mysql >> /var/log/imagine.log
#Enable MOD rewrite 
sudo a2enmod rewrite >> /var/log/imagine.log
##########################################
echo 'Finally Checking status of services' >> /var/log/imagine.log
##########################################
##########################################
echo Apache service is $(systemctl show -p ActiveState --value apache2) >> /var/log/imagine.log
##########################################
##########################################
echo MySQL DB service is $(systemctl show -p ActiveState --value mysql)  >> /var/log/imagine.log
##########################################
#Install is Complete######################
echo LAMP setup installed on ubuntu Successfully >> /var/log/imagine.log
#Copy framework to html directory
sudo wget https://github.com/yiisoft/yii/releases/download/1.1.25/yii-1.1.25.43e386.zip
sudo unzip yii-1.1.25.43e386.zip
cd yii-1.1.25.43e386 
sudo mv framework/ /var/www/html/ 
#Downloading Yii pre-loaded app for test
git clone https://github.com/01010101Basics/imaginelabsdemo.git >> /var/log/imagine.log
sudo mv imaginelabsdemo /var/www/html/
sudo cp /var/www/html/imaginelabsdemo/000-default.conf /etc/apache2/sites-available >> /var/log/imagine.log
#restart apache
sudo service apache2 restart 
#Set App Path
yii_app_path=/var/www/html/imaginelabsdemo >> /var/log/imagine.log
#importing user db and table
sudo mysql < /var/www/html/imaginelabsdemo/users.sql
#changing ACL's for directories
sudo chmod -vR 0777 $yii_app_path/assests >> /var/log/imagine.log
sudo chmod -vR 0777 $yii_app_path/protected/runtime >> /var/log/imagine.log
#Change ownership of directories so the application can change values (e.g. GII)
sudo chown -vR www-data $yii_app_path/assets >> /var/log/imagine.log
sudo chown -vR www-data $yii_app_path/protected/runtime >> /var/log/imagine.log
sudo chmod -vR 0744 $yii_app_path/assets >> /var/log/imagine.log
sudo chmod -vR 0744 $yii_app_path/protected/runtime >> /var/log/imagine.log
#Install Docker
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common && 
sudo apt-get install docker.io -y &&
sudo usermod -aG docker-ubuntu
