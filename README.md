# Sys Admin & Network CFITECH
 
--------------------------------------


2  sudo apt update
    3  sudo apt upgrade -y
    4  sudo apt install apache2 -y
    5  ip a
    6  sudo apt install mysql-server -y
    7  sudo apt install php libapache2-mod-php php-mysql -y
    8  sudo apt install php-cli php-xml php-mbstring php-mysql php-intl php-json php-curl php-zip -y
    9  sudo nano /var/www/html/info.php
   10  sudo systemctl restart apache2
   11  sudo mysql -u root -p
   12  sudo nano /var/www/html/db_test.php
   13  sudo systemctl restart apache2
   14  sudo systemctl status apache2
   15  sudo nano /etc/apache2/apache2.conf
   16  sudo apachectl configtest
   17  sudo systemctl restart apache2
   18  sudo systemctl status apache2
   19  sudo nano /etc/apache2/sites-available/000-default.conf
   20  sudo a2ensite 000-default.conf
   21  sudo systemctl reload apache2
   22  sudo systemctl status apache2
   23  sudo mysql -u root -p
   24  sudo nano /var/www/html/db_test.php
   25  ip a
   26  sudo nano /var/www/html/db_test.php
   27  php -v
   28  sudo apt install curl
   29  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
   30  curl -sS https://getcomposer.org/installer | php 
   31  sudo mv composer.phar /usr/local/bin/composer
   32  composer --version
   33  curl -sS https://get.symfony.com/cli/installer | bash
   34  composer --version
   35  sudo mv /home/$(whoami)/.symfony*/bin/symfony/usr/local/bin/symfony
   36  sudo mv /home/$(whoami)/.symfony*/bin/symfony /usr/local/bin/symfony
   37  symfony -v
   38  symfony new mon_projet_symfony --webapp
   39  ls
   40  cd mon_projet_symfony/
   41  symfony server:start
   42  sudo nano /etc/apache2/sites-available/intranet.conf
   43  sudo a2ensite mon_projet_symfony.conf
   44  sudo mv /etc/apache2/sites-available/intranet.conf /etc/apache2/sites-available/mon_projet_symfony.conf
   45  sudo a2ensite mon_projet_symfony.conf
   46  sudo a2enmod rewrite
   47  sudo systemctl restart apache2
   48  systemctl restart apache2
   49  sudo systemctl status apache2.service
   50  sudo nano /etc/apache2/sites-available/mon_projet_symfony.conf
   51  sudo systemctl restart apache2
   52  sudo systemctl status apache2
   53  sudo nano /etc/apache2/sites-available/mon_projet_symfony.conf
   54  sudo systemctl restart apache2
   55  sudo systemctl status apache2
   56  sudo nano /etc/apache2/sites-available/mon_projet_symfony.conf
   57  sudo systemctl restart apache2
   58  sudo systemctl status apache2
   59  sudo nano /etc/apache2/sites-available/mon_projet_symfony.conf
   60  sudo systemctl restart apache2
   61  sudo systemctl status apache2
   62  lamp@lamp:~/mon_projet_symfony$ sudo systemctl status apache2
   63  ● apache2.service - The Apache HTTP Server
   64  Feb 17 12:16:16 lamp systemd[1]: Starting The Apache HTTP Server...
   65  Feb 17 12:16:16 lamp apachectl[27771]: AH00112: Warning: DocumentRoot [/var/www/html/mon_projet_symfony/public] does not exist
   66  Feb 17 12:16:16 lamp systemd[1]: Started The Apache HTTP Server.
   67  ls -ld /var/www/html/mon_projet_symfony/public
   68  sudo ls -ld /var/www/html/mon_projet_symfony/public
   69  sudo nano /etc/apache2/sites-available/mon_projet_symfony.conf
   70  sudo systemctl restart apache2
   71  sudo systemctl status apache2
   72  sudo nano /etc/hosts
   73  cat /etc/hosts
   74  sudo nano /etc/hosts
   75  sudo Forbidden
   76  You don't have permission to access this resource.
   77  Apache/2.4.52 (Ubuntu) Server at mon_projet_symfony.local Port 80
   78  sudo ls -ld /home/lamp/mon_projet_symfony/public
   79  sudo chown -R www-data:www-data /home/lamp/mon_projet_symfony
   80  sudo ls -ld /home/lamp/mon_projet_symfony/public
   81  sudo chmod -R 755 /home/lamp/mon_projet_symfony
   82  sudo chmod +x /home/lamp
   83  sudo nano /etc/apache2/sites-available/mon_projet_symfony.conf
   84  sudo apachectl configtest
   85  sudo systemctl restart apache2
   86  sudo systemctl status apache2
   87  sudo aa-status
   88  sudo nano /etc/apparmor.d/usr.sbin.apache2
   89  sudo systemctl reload apparmor
   90  sudo nano /etc/apparmor.d/usr.sbin.apache2
   91  sudo rm /etc/apparmor.d/usr.sbin.apache2
   92  sudo mysql -u root -p
   93  sudo nano .env
   94  ls
   95  php bin/console doctrine:database:migrate
   96  composer require symfony/orm-pack
   97  composer require --dev symfony/maker-bundle
   98  git config --global --add safe.directory /home/lamp/mon_projet_symfony
   99  ls -la /home/lamp/mon_projet_symfony
  100  sudo chown -R lamp:lamp /home/lamp/mon_projet_symfony
  101  sudo chmod -R 775 /home/lamp/mon_projet_symfony
  102  composer require symfony/orm-pack
  103  composer require --dev symfony/maker-bundle
  104  git status
  105  composer show
  106  php bin/console doctrine:database:create
  107  php -m | grep pdo_mysql
  108  sudo nano /var/www/html/test_pdo.php
  109  php -v
  110  php8.1 bin/console doctrine:database:create
  111  extension=pdo_mysql
  112  apache2ctl -M | grep php
  113  extension=pdo_mysql
  114  sudo systemctl restart apache2
  115  php8.1 bin/console doctrine:database:create
  116  ls
  117  cat compose.yaml 
  118  sudo apt-get install qemu-guest-agent
  119  sudo systemctl start qemu-guest-agent
  120  sudo systemctl enable qemu-guest-agent
  121  sudo systemctl status qemu-guest-agent
  122  php -v
  123  php8.1 bin/console doctrine:database:create
  124  ls
  125  sudo nano .env
  126  sudo apt install php-mysql
  127  extension=pdo_mysql
  128  sudo systemctl restart apache2
  129  sudo nano .env
  130  sudo apt install mysql-client -y
  131  composer config allow-plugins true
  132  composer remove symfony/postgresql
  133  composer require symfony/orm-pack
  134  php bin/console doctrine:database:create
  135  sudo php bin/console doctrine:database:create
  136  sudo nano .env
  137  sudo mysql -u root -p
  138  mysql -u root -p
  139  sudo systemctl stop mysql
  140  sudo mysqld_safe --skip-grant-tables &
  141  mysql -u root
  142  sudo mysql -u root
  143  sudo systemctl status mysql
  144  sudo mysqld_safe --skip-grant-tables &
  145  sudo systemctl restart mysql
  146  sudo systemctl status mysql
  147  sudo mysql -u root
  148  sudo systemctl stop mysql
  149  sudo mysqld_safe --skip-grant-tables &
  150  mysql -u root
  151  sudo systemctl start mysql
  152  sudo systemctl status mysql
  153  sudo systemctl start mysql
  154  mysql -u root -p
  155  sudo mkdir -p /var/run/mysqld/
  156  sudo chown mysql:mysql /var/run/mysqld/
  157  sudo chmod 755 /var/run/mysqld/
  158  sudo systemctl restart mysql
  159  sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
  160  sudo systemctl restart mysql
  161  pdo_mysql.default_socket = /var/run/mysqld/mysqld.sock
  162  sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
  163  php bin/console doctrine:database:create
  164  sudo nano .env
  165  sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
  166  mysql -u root -p
  167  php bin/console doctrine:database:create
  168  php bin/console doctrine:migrations:migrate
  169  ls src/Entity
  170  php bin/console make:entity
  171  mysql -u root -p


--------------------------------------------------------

