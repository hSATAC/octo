---
layout: post
title: "整合 Jenkins 和 Docker"
date: 2014-06-29 22:51
comments: true
categories: [CI, Jenkins, Docker, Rspec, Rails, RoR]
---

這篇將會記述一些我自己整合 Jenkins CI 和 Docker 的思路、想法、要點以及備忘。不會有 step by step 的教學，若有此類需求請參考最後附錄。

## Why Docker?

Jenkins 跑的好好的，為什麼要摻 Docker 呢？原本我們 Rails Rspec 跑的其實也不錯，但受限於 database 以及 elasticsearch, redis 等 services，無法同時跑多個 worker, 再加上未來若有平行化測試以及多個專案 / 不同 db 版本等等的需求，引入 docker 可以完美解決這些問題。

## Concept

使用 Docker 的好處就是原本的 shell script 幾乎都不用改即可繼續使用，引入的門檻降到極低。

基本概念是建立一個可以跑 Rails app 起來的環境，然後把整個 CI 的 workspace 丟進去跑測試，其他的步驟都一模一樣。

在建立環境這邊基本上有兩個選擇，一種是全部包成一個 image, 就用這個 container 來跑測試。另一種是每個需要的 service 都是一個各自的 container, 彼此之間透過 [Docker Container Linking](https://docs.docker.com/userguide/dockerlinks/) 來通訊，例如 postgresql 自己一個、elasticsearch 自己一個、rails 自己一個這樣。

不過由於跑測試都是用過即丟，這次我直接採用最簡單的包一大包的策略來進行，減少複雜度。
<!--more-->
我會選擇自己 Build docker 來跑測試主要是還想運用在其他地方，包括 trigger 不同的瀏覽器跑 feature tests 而不需重新 Build docker image 等等，如果沒有特殊需求的話也可以參考看看 Jenkins 的 [Docker Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin) 基本概念是直接把 Jenkins slave 用 docker 跑起來。可以評估看看自己是否合用。

### Base Image

我的設計是先建立一個 base image 例如給他 tag 叫 `project/base` 裡面先預裝好了所有環境包括 pg, elasticsearch, redis, rvm, ruby 等等。

舉例來說可能長這樣：

```
FROM ubuntu:12.04
MAINTAINER hSATAC

# We use bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# We don't like apt-get warnings.
ENV DEBIAN_FRONTEND noninteractive

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update the Ubuntu and PostgreSQL repository indexes
RUN apt-get update

# === Locale ===
RUN locale-gen  en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# === Requirements ===
RUN apt-get -y -q install nodejs libpq-dev wget git curl imagemagick vim postfix

RUN cd /tmp &&\
	wget http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.0/wkhtmltox-linux-amd64_0.12.0-03c001d.tar.xz &&\
	tar Jxvf wkhtmltox-linux-amd64_0.12.0-03c001d.tar.xz &&\
	cd wkhtmltox &&\
	install bin/wkhtmltoimage /usr/bin/wkhtmltoimage

# === Redis ===
RUN apt-get -y -q install redis-server

# === Elasticsearch ===
RUN apt-get install openjdk-7-jre-headless -y -q
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb
RUN dpkg -i elasticsearch-1.1.0.deb

# === RVM ===
RUN curl -L https://get.rvm.io | bash -s stable
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /bin/bash -l -c rvm requirements
RUN source /usr/local/rvm/scripts/rvm && rvm install ruby-2.1.2
RUN rvm all do gem install bundler

# === Postgresql ===
RUN apt-get -y -q install python-software-properties software-properties-common
RUN apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

# Update template1 to enable UTF-8 and hstore
USER postgres
RUN    /etc/init.d/postgresql start &&\
    psql -c "update pg_database set datistemplate=false where datname='template1';" &&\
    psql -c 'drop database Template1;' &&\
    psql -c "create database template1 with owner=postgres encoding='UTF-8' lc_collate='en_US.utf8' lc_ctype='en_US.utf8' template template0;" &&\
    psql -c 'CREATE EXTENSION hstore;' -d template1

# Create a PostgreSQL role and db
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE ROLE jenkins LOGIN PASSWORD 'jenkins' SUPERUSER INHERIT CREATEDB NOCREATEROLE NOREPLICATION;" &&\
    createdb -O jenkins jenkins_test &&\
    createdb -O jenkins jenkins_production


# Adjust PostgreSQL configuration
RUN echo "local all  all  md5" > /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
```

### Test Image

接著用 `project/base` build 一個 `project/test`，這個 image 會安裝一些「只有測試會用到」的套件，順便把 Gemfile 複製進去安裝一下 Gem, 這樣到時在跑測試的時候就可以省略 `bundle install` 的時間了。因為我的 base image 還有打算拿來做其他用途，所以這邊是這樣設計。

每天凌晨三點左右用 crontab 重新 Build 一次這個 `project/test` 的 image 以更新 gems. 當然這邊牽涉到一些如何同步你專案中的 Gemfile 不過這都是簡單的 script 可以解決的問題，這邊不贅述。

```
FROM project/base

# Switch back to root
USER root

# Set ENV
ENV RAILS_ENV test

# Preinstall gem
ADD gem /opt/project_gem # 這個 gem 目錄裡面有 Gemfile 和 Gemfile.lock
WORKDIR /opt/project_gem
RUN rvm all do bundle install

# Install Firefox & Xvfb
RUN apt-get -y install firefox xvfb # 跑 selenium test 用的

# Onbuild witch back to root
ONBUILD USER root

# Mound Rails directory
ONBUILD ADD . /opt/project
ONBUILD WORKDIR /opt/project

# Bundle install
ONBUILD RUN rvm all do bundle install

# Go
ONBUILD ADD start_services.sh /opt/project/start_services.sh
ONBUILD RUN chmod +x /opt/project/start_services.sh
ONBUILD ADD run_tests.sh /opt/project/run_tests.sh
ONBUILD RUN chmod +x /opt/project/run_tests.sh
ONBUILD CMD /opt/project/start_services.sh && /opt/project/run_tests.sh
```

注意這邊最後一段用到了上一篇文章 [Docker Basics](/2014/06/docker-basics/) 中所講到的 ONBUILD, 使用這個功能我們就可以很輕鬆的 build 出真正用來測試的 Image.

這幾行實際做的動作是複製兩個 scripts 分別名叫 `start_services.sh` 和 `run_tests.sh` 並且 `CMD` 預設執行這兩個檔案。

但是這兩個檔案現在實際不存在，我會透過 jenkins 的 build scripts 來寫這兩個檔案，其實也就是原本在 build scripts 的內容移到這兩個檔案中了。之所以不把這兩個檔案存在某處再複製過來，就是想保留原本在 Jenkins configure 可以調整 Build Script 的機制，多留一點彈性。

為什麼要這麼麻煩使用 ONBUILD + CMD ，而不是直接 RUN 然後最後直接看 Image 有沒有建置成功就好？除了上述想多留一點彈性的原因外，還有用 Build 這樣 Build 的過程勢必會跑這兩支 script, 而我有可能 Build 完以後不跑這兩支 script, 而是做一些其他的動作例如 `/bin/bash` 進去 debug 等等，當然可以透過改寫這兩支 script 的內容來使 Build 過程不跑測試，但增添了複雜度。使用這個機制我覺得是最有彈性的。

### Jenkins Build Script

Jenkins build script 這邊改動的幅度不大，原本的流程大概是：

1. 改好相關 application.yml, database.yml 等等 local 設定檔並塞進去。

2. 跑 db:reset 等等重置環境

3. 跑測試

基本步驟還是一樣，第一步可以完全不用變，後面就得修改一下，例如：

```
# Start services in docker
echo "
Xvfb :99 -screen 0 1366x768x24 -ac 2>/dev/null >/dev/null &
/etc/init.d/postgresql start &&\
/etc/init.d/redis-server start &&\
/etc/init.d/elasticsearch start
" > start_services.sh

# Run tests
echo "
rvm all do bundle exec rake db:migrate &&\
DISPLAY=:99 rvm all do bundle exec rspec spec --format=documentation
" > run_tests.sh

echo "FROM project/test" > Dockerfile
docker build --rm -t project/$BUILD_NUMBER .
docker run --rm project/$BUILD_NUMBER
```

一開始用 echo 寫入兩個檔案，內容大致就是開啟 service 並且開始跑測試，值得注意的是我們在 Jenkins workspace 裡寫了一個新的 Dockerfile, 裡面只有一行內容 `FROM project/test` 配合之前的 `ONBUILD` 就可以建置出這個 image. 之所以不直接用 `<` 的方式把內容丟到 `docker build` 指令，是因為 `ADD` 需要 context, 也就是 Jenkins workspace, 所以必須要寫實體的檔案出來。

Image tag 直接取用 Jenkins 的環境變數 `$BUILD_NUMBER` 因此像第 300 個 build 他的 image 就會叫 `project/300` 清楚明瞭。

Build 和 Run 都使用 `--rm` 來確保跑完以後就刪除，節省系統空間。當然如果有保留的需求，例如這個跑完以後自動 trigger 一個專門測 IE 的 selenium test target 的話這邊是可以不用刪除的，看個人需求。

Build 完以後也可以同時跑好幾個 containers，利用一個 image 可以跑很多 containers 的特性，例如把 spec 目錄分成幾區，同時開始跑測試，這樣平行處理可以節省時間。

這邊有一個問題就是 `docker run` 理論上要回傳 command 的 exit code 不過這部分常常出問題，[時好時壞](https://github.com/dotcloud/docker/issues/6259) 所以這邊我決定自己來處理。

想法很簡單，直接把 `docker run` 的 output 拿來檢查，有偵測到爆炸的話就寫一個檔案，最後來檢查檔案，如果沒過就手動爆炸。等這個 bug 修復穩定之後，就可以不要使用這個 workaround 了。

```
docker run --rm project/$BUILD_NUMBER | perl -pe '/Failed examples:/ && `echo "fail" > docker-tests-failed`'
docker rmi project/$BUILD_NUMBER

if [ ! -f docker-tests-failed ]; then
  echo -e "No docker-tests-failed file. Apparently tests passed."
else
  echo -e "docker-tests-failed file found, so build failed."
  rm docker-tests-failed
  exit 1
fi
```

如果你沒有遇到這個問題，或者你是使用 [rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter) 之類的套件產生 JUnit 檔案的話並加掛 Post-build action 的話，這個動作會讀 JUnit 檔案的內容來改變 Build result 因此也不需要這個 workaround.

## 其他整合

* Jenkins 有一個 plugin [Github Pull Request Builder](https://wiki.jenkins-ci.org/display/JENKINS/GitHub+pull+request+builder+plugin) 可以讓 Jenkins 像 travis-ci 那類 service 在 Github 有人發 PR 時自動抓回來 Build。

* Hipchat plugin 可以整合到公司通訊軟體。

* [rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter) 可以把 rspec 的結果產生成 JUnit 的 xml 給 Jenkins 讀取。

* Test Coverage 的部分我們則是使用 [SimpleCov](https://github.com/colszowka/simplecov) 可以搭配 [SimpleCov Rcov Formatter](https://github.com/fguillen/simplecov-rcov) 產生 Jenkins 可讀的報表。

要使用以上這兩個套件，必須在測試跑完以後使用 `docker cp <file> .` 指令把報表複製回 workspace 讓 Jenkins 讀取。

## 參考連結

這邊列出一些不錯的連結：

* [Docker quicktip #3 – ONBUILD](http://www.tech-d.net/2014/02/06/docker-quicktip-3-onbuild/)
* [Integrating Docker with Jenkins for continuous deployment of a Ruby on Rails application](http://www.powpark.com/blog/programming/2014/01/29/integrating-docker-with-jenkins-for-ruby-on-rails-app)
* [Using Docker To Run Ruby Rspec CI In Jenkins](http://www.activestate.com/blog/2014/01/using-docker-run-ruby-rspec-ci-jenkins)
* [Your Dockerfile for Rails](http://blog.gemnasium.com/post/66356385701/your-dockerfile-for-rails)
* [Using Docker to Parallelize Rails Tests](http://ngauthier.com/2013/10/using-docker-to-parallelize-rails-tests.html)
* [How to Set Up TravisCI-like Continuous Integration with Docker and Jenkins](https://zapier.com/engineering/continuous-integration-jenkins-docker-github/)