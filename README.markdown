Feed Tracking Tool
==================

Feed Tracking Tool (FTT) is a web-based RSS/Atom feed tracker running on Ruby on Rails. It lets multiple users define "trackers" to filter content provided by feeds. Matching content are aggregated and sent by mails to subscribed users.


Status
------

This project is no longer maintained and is quite outdated. Unless people are willing to contribute to this project and clean it up, it should be considered as an ugly legacy code base. So please be indulgent while looking at FTT code: it was the work of unexperienced RoR developers ! ;)


Features
--------

* Can track several formats of feed (Atom, RSS, ...)
* Can track static pages
* Trackers can be private or public
* Each tracker has its own mailing frequency
* Users are sourced from an LDAP directory


Technology
----------

* Framework: Ruby on Rails
* Database: MySQL
* Feed parsing: [FeedTools](http://sporkmonger.com/projects/feedtools/)
* Mail transfer agent: [MSMTP](http://msmtp.sourceforge.net/)


Support
-------

* Documentation: http://github.com/kdeldycke/feed-tracking-tool/blob/master/README
* Bug tracker: http://github.com/kdeldycke/feed-tracking-tool/issues
* Source code / Home page: http://github.com/kdeldycke/feed-tracking-tool


Ruby on Rails setup
-------------------

1.  Install a Ruby on Rails development environment:

        $ apt-get install ruby rubygems

    Eventually register your HTTP proxy:

        $ export HTTP_PROXY='http://12.34.56.78:8080'

    Install all other libraries with gem:

        $ gem update --system
        $ gem install rails mysql feedtools ruby-net-ldap daemons slave feedalizer -y

1.  Get the list of local gems:

        $ gem query --local

    and check that the followings gems are installed:

      * actionmailer
      * actionpack
      * actionwebservice
      * activerecord
      * activesupport
      * builder
      * daemons
      * feedtools
      * rails
      * rake
      * ruby-net-ldap
      * slave
      * sources
      * uuidtools

    Some of them are Rails dependencies and as such are automatically installed. Those who are not can be installed with the following command:

        $ gem install <gem>

1.  Install the MySQL server:

        $ apt-get install mysql-server

1.  Install msmtp with your favorite package manager. Example:

        $ apt-get install msmtp

1.  Get a copy of FTT in your system web folder:

        $ git clone git@github.com:kdeldycke/feed-tracking-tool.git /var/www/

1.  Create a MySQL database and update the `config/database.yml` file accordingly:

        $ mysql -h localhost -u root --disable-pager -e "CREATE DATABASE IF NOT EXISTS FTT_development;"
        $ mysql -h localhost -u root --disable-pager -e "CREATE DATABASE IF NOT EXISTS FTT_test;"
        $ mysql -h localhost -u root --disable-pager -e "CREATE DATABASE IF NOT EXISTS FTT_production;"
        $ vi config/database.yml

1.  Update RoR version in the `config/environnment.rb` file to make it match the RoR version installed on your system:

        RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

    To get the currently installed version of RoR, use this command:

        $ gem query --local rails

1.  Check that FTT is in production mode in `config/database.yml` by uncommenting the following line:

        # ENV['RAILS_ENV'] ||= 'production'

1.  Create all database tables:

        $ rake db:schema:load RAILS_ENV=production

1.  If your app is behind a proxy, don't forget to update the `HTTP_PROXY_HOST` and `HTTP_PROXY_PORT` constants in `config/environnment.rb`.

1.  Update the `config/backgroundrb.yml` with the following directive:

        :rail_env: production


Apache / FastCGI setup
----------------------

1.  Install fcgid:

        $ apt-get install libapache2-mod-fcgid libfcgi-ruby1.8

1.  Activate the fcgid module:

        $ a2enmod fcgid
        $ /etc/init.d/apache2 restart

1.  In the `public/.htaccess` file, replace:

        AddHandler fastcgi-script .fcgi

    by:

        AddHandler fcgid-script .fcgi

    Also check that these rewrite rules are present in that file:

        RewriteEngine On
        RewriteBase /feed-tracking-tool

        RewriteRule ^$ index.html [QSA]
        RewriteRule ^([^.]+)$ $1.html [QSA]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ dispatch.fcgi [QSA,L]

1.  Update the default Virtual Host from `/etc/apache2/sites-available/default` with these directives:

        <VirtualHost *>
          ServerAdmin webmaster@localhost

          DocumentRoot /var/www
          RewriteEngine On

          [...]

          Alias /images/ /var/www/feed-tracking-tool/public/images/
          RewriteCond %{REQUEST_URI} !^/feed-tracking-tool/public
          RewriteRule ^/feed-tracking-tool(/.*)?$   /feed-tracking-tool/public$1
          <Directory /var/www/feed-tracking-tool/public/>
            Options FollowSymLinks ExecCGI
            AllowOverride All
            Order allow,deny
            Allow from all
          </Directory>

        </VirtualHost>

1.  Active Apache rewrite mode:

        $ cd /etc/apache2/mods-enabled/
        $ ln -s ../mods-available/rewrite.load

1.  Fix app's rights to let Apache handle them:

        $ chown www-data:root -R /var/www/feed-tracking-tool

1.  Fix some others file rights and ownership:

        $ cd /var/www/feed-tracking-tool
        $ chmod 755 public
        $ chmod 755 public/dispatch.fcgi
        $ chmod -R 775 log
        $ chmod -R 775 tmp

1.  Restart Apache:

        $ /etc/init.d/apache2 restart

1.  Restart FTT's background tasks handler:

        $ ruby script/backgroundrb stop
        $ ruby script/backgroundrb start

1. Goto `http://my-domain.com/feed-tracking-tool`.


Roadmap
-------

* 0.11.0
  * Update all this legacy code to latest Ruby, Ruby on Rails and third-party libraries
  * Update and simplify installation procedure


TODO-list
---------

* Report here all TODO's found in the code


Changelog
---------

* **0.10.1-trunk** (2011-03-21)
  * First Open-source public release

* **0.10.0** (2007-09-21)

* **0.9.1** (2007-09-12)

* **0.9.0** (2007-09-12)

* **0.8.3** (2007-09-07)

* **0.8.2** (2007-09-06)

* **0.8.1** (2007-09-03)

* **0.8** (2007-08-31)

* **0.7** (2007-08-30)

* **0.6** (2007-08-24)

* **0.5** (2007-08-23)

* **0.4.1** (2007-08-21)

* **0.0** (2007-07-17)
  * First HTML mockup


Contributors
------------

* [Kevin Deldycke](http://kevin.deldycke.com): latest development
* Quentin Desert: initial development
* [Julien La Vinh](http://julien.la-vinh.fr): initial specifications


History
-------

This tool was developed within [Uperto](http://uperto.com), the Open-Source business unit of the [Devoteam group](http://devoteam.com), for its internal needs.

The project had an ancestor written in 2006 that was based on Pylons (Python framework). This was in a prototype stage and was barely working. Iterating over the abandoned Pylons code base was considered a waste of time. So in summer 2007, it was decided to rewrite this application from scratch.

As Quentin was available and already played with Ruby on Rails, he was asked to create the initial code base. Kevin joined the project early as he was eager to experiment with Ruby on Rails.

This app was known under different names before settling to FTT. Those includes:

  * VTP, a French acronym for "Veille Technologique Passive"; and
  * OVT, another French acronym for "Outil de Veille Technologique".

This explain why you may find these two acronyms and some other French comments in FTT's legacy code base.

At the end FTT was essentially a test project to explore and play with Ruby on Rails. It was never deployed in production and was never used for Uperto's internal needs.

After roting for more than 3 years in Uperto's backups, and representing absolutely no business value in itself, [Kevin decided in 2011 to release code](http://kevin.deldycke.com/2011/03/feed-tracking-tool-released-open-source-license/) (with Uperto's approval) under an open-source license. The initial intention of this open-source release was to share back knowledge and code with the community.


License
-------

This program is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License** as published by the Free Software Foundation, either **version 2** of the License, **or any later version**.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/gpl-2.0.html
