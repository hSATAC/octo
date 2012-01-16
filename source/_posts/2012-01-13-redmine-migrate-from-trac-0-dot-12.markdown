---
layout: post
title: "Redmine migration from Trac 0.12"
date: 2012-01-13 14:03
comments: true
categories: [Redmine, Trac]
---
This article will demostrate a near perfect redmine migration from trac 0.12 step by step.

* [Install Redmine on CentOS 5](http://www.redmine.org/projects/redmine/wiki/HowTo_install_Redmine_on_CentOS_5)
  * Install Ruby
  * Install rubygem
  * Install passenger
    * /etc/conf.d/ruby.conf
```
LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-3.0.11/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-3.0.11
PassengerRuby /usr/bin/ruby
```
    * /etc/httpd/conf.d/redmine.conf
```
   <VirtualHost *:80>
      ServerName redmine.miiicasa.com 
      DocumentRoot /home/m/share/htdocs/redmine/public
      <Directory /home/m/share/htdocs/redmine/public>
         AllowOverride all    
         Options -MultiViews    
      </Directory>
   </VirtualHost>
```
<!--more-->
  * Get Redmine source from [miiiCasa github repo](https://github.com/miiicasa/redmine) (bundler integrated and migrate_from_trac.rake modified)
  * install bundler and bundle install
```
sudo gem install bundler
bundle install
```
  * Setup mysql database and user
```
create database redmine character set utf8;
create user 'redmine'@'localhost' identified by 'my_password';
grant all privileges on redmine.* to 'redmine'@'localhost';
```
  * cp config/database.yml.example config/database.yml and modify it based on previous settings.
  * cp config/configure.yml.example config/configure.yml and modify it.
  * Generate the session store
```
RAILS_ENV=production bundle exec rake generate_session_store
```
  * Migrate the database models
```
RAILS_ENV=production bundle exec rake db:migrate
```
  * Load default data
```
RAILS_ENV=production bundle exec rake redmine:load_default_data
```

* Migrate from trac
  * install sqlite3-ruby
```
sudo gem install sqlite3-ruby
```
  * migrate from trac
```
RAILS_ENV=production bundle exec rake redmine:migrate_from_trac
...
Are you sure you want to continue ? [y/N] y                     

Trac directory []: /var/www/trac/miiicasa
Trac database adapter (sqlite, sqlite3, mysql, postgresql) [sqlite3]:
Trac database encoding [UTF-8]: 
Target project identifier []: miiicasa
```

  * git clone https://github.com/xfalcons/migrate-trac-to-redmine.git
  Follow the instruction.

* Setup Redmine
  * Make all users admin:
```
$ RAILS_ENV=production ./script/console
..
for u in User.all
  u.admin = true
  u.save
end
```

  * Login and setup scm path
  * Load git repo from script (prevent timeout)
```
$ ruby script/runner "Repository.fetch_changesets" -e production
```
  This action could take a very long time (maybe 1 day) and it got no progress bar nor any output. If you want to check where it went, try:
```
ps axww | grep git | grep -v grep
```
  You'll see it's parsing git log.