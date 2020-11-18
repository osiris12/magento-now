# Create a Magento 2 development environment on Windows.

This guide walks users through creating a virtual machine that runs Debian/Stretch along with all of Magento's server requirements needed to run a Magento 2 installation.

## Local System Requirements
* [Vagrant](https://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/)
* [Git](https://git-scm.com/)

## What we are installing on the virtual machine
* [DebianStretch OS](https://wiki.debian.org/DebianStretch)
* [PHP 7.3](https://www.php.net/)
* [Mariadb 10.1](https://mariadb.org/)
  - Database: magento2
  - User: vagrant
  - Password: hashi
* [Apache 2.4](https://httpd.apache.org/)
* [Elasticsearch 6.x](https://www.elastic.co/)
* [cURL](https://curl.se/)
* [Composer](https://getcomposer.org/)
* [Git](https://git-scm.com/)
* [Java SE Development Kit 8](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html)

## Installation Process
#### This solution uses NFS. In order to use NFS with Vagrant on Windows, we need to install [this Vagrant NFS plugin](https://github.com/winnfsd/vagrant-winnfsd). Simply open a command prompt and run the following command to install the NFS plugin: 
> vagrant plugin install vagrant-winnfsd
### Steps
1. Create a folder on your computer where you will store your Magento projects.
> **Example:** C:\Users\\*user*\\*magento-projects*
2. Open a command prompt. cd into your Magento projects folder and clone this repository.
> cd C:\Users\\*user*\\*magento-projects* <br/>
> git clone https://github.com/osiris12/magento-now.git
3. Once the repo has been cloned, cd into the repo directory and create a new folder called ‘src’. This will hold your Magento project.
> cd C:\Users\\*user*\\*magento-projects*\\*magento-now* <br/>
> mkdir src
4. Head over to [Oracle](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html) and download the Linux x64 Compressed Archive file and place it in your 'hashi' folder. 
![linux-java-tar](https://user-images.githubusercontent.com/13813761/99601131-6e8d1280-29c4-11eb-86b2-5f08c76ebe5b.PNG)
5. cd into the 'hashi' directory and run ‘vagrant up’. This will begin the setup of your virtual machine server with all the necessary Magento 2.3.x requirements.
> cd C:\Users\\*user*\\*magento-projects*\\*magento-now*\\*hashi* <br/>
> vagrant up
6. Once it’s complete, run ‘vagrant ssh’ and you will be in your virtual machine. From here you can check that your local machine's 'src' folder is synced with your virtual machines '/var/www/html' directory. If you cd into '/var/www/html' you should find a 'index.html' file both in your virtual machine and your local 'src' folder. If you delete it either locally or on your VM, it should delete on the other as well.
7. You're now ready to clone the Magento 2 repo.
