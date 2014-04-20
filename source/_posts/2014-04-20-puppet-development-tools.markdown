---
layout: post
title: "Puppet Development Tools"
date: 2014-04-20 13:36
comments: true
categories: [Puppet, Vagrant]
---


好一陣子沒寫 Puppet, 最近回來研究發現多了不少好用的工具，可以有效加速開發速度。

## Vagrant

現在 [Vagrant](http://www.vagrantup.com/) provisioner 直接提供了 [Puppet 選項](http://docs.vagrantup.com/v2/provisioning/puppet_apply.html)，可以幫你 sync hiera, manifests, modules 進去直接 run，也可以帶入 custom options 或是 factor，在開發 modules 的時候可以不用管其他東西，專心 focus 在 pp 本身。

只要在 Vagrantfile 裡面加入這樣的設定即可：

```
  # Puppet config
  config.vm.provider "virtualbox" do |vb, override|
    override.vm.provision "puppet" do |puppet|
      puppet.options = "--parser future --verbose --debug" # For debug only
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "vagrant.pp"
      puppet.module_path    = "modules"
      puppet.hiera_config_path = "hiera.yaml"
    end
  end
```

不過有兩個小地方需要注意：
<!-- more -->
### Puppet 版本

Vagrant 附的 Puppet 版本比較舊，是 2.7x。如果有新版本的需求，可以使用這隻 script 來升級 Puppet：

<script src="https://gist.github.com/hSATAC/11106132.js"></script>

```
  # Upgrade Puppet from 2.7 to 3.x
  config.vm.provision :shell, :path => "scripts/upgrade_puppet.sh"
```

### Hiera 目錄

通常 hiera 不會只有一隻檔案，但 Vagrant 只會幫你掛上 modules 和 manifests 資料夾。這時就需要把 hiera 的目錄丟到 manifests 下面，並且在 hiera 設定 `:datadir: "%{settings::manifestdir}/hieradata"` 直接去吃 manifests 的路徑即可。

---

## Librarian-Puppet

[Librarian-Puppet](http://librarian-puppet.com/) 是一個管理 puppet modules 的工具，基本上跟 bundler 的概念一樣。編寫 Puppetfile 以後，使用指令 `librarian-puppet install` 來安裝到 `modules` 目錄下。這樣就不用處理 `puppet module install` 和指定版本，以及安裝自己 private modules 的問題了。反正使用 librarian-puppet 他會幫你管好一個 `modules` 目錄。

Puppetfile 支援幾種指定方式，都非常實用：

```
modulefile
```

只要直接下 modulefile 他就會去吃你 modulefile 裡面的 dependencies。這在開發 puppet modules 的時候會用到。

```
mod "puppetlabs/stdlib"
```

指定 puppet forge 的 package name。

```
mod "puppetlabs/apt",
  :git => "git://github.com/puppetlabs/puppetlabs-apt.git",
  :ref => '0.0.3'
```

指定某 repo 的 ref。

```
mod "puppetlabs/apt",
  :git => "git://github.com/fake/puppet-modules.git",
  :path => "modules/apt"
```

指定 repo 下的 path。

```
mod "puppetlabs/apt", :path => "modules/apt"
```

指定 local path，可以用在 private modules。

---

## Puppet Skeleton

以上這兩個工具搭配起來，開發 Puppet 就變得很容易了：把需要的 community modules 定義在 Puppetfile 裡面，private modules 放在 local, 一樣用 Puppetfile 掛起來安裝，再透過 Vagrant 指定 manifest path, file, hiera 的設定，直接 `$ vagrant up` 就可以反覆測試 puppet 了。

我有做了一個 [puppet-skeleton](https://github.com/hSATAC/puppet-skeleton) 的專案，這是我自己開發 Puppet 的專案架構跟 workspace。

### Rake Tasks

這邊是一些我自己開發常用的 rake tasks，基本上就是省 keysroke...

```bash
$ rake -T                                  # List all tasks.
$ rake -D                                  # List all tasks with descriptions.
$ rake module:lint                         # Puppet lint.
$ rake module:reinstall                    # Clean and reinstall modules.
$ rake module:sync                         # Sync private modules.
$ rake syntax                              # Syntax check Puppet manifests and templates
$ rake syntax:hiera                        # Syntax check Hiera config files
$ rake syntax:manifests                    # Syntax check Puppet manifests
$ rake syntax:templates                    # Syntax check Puppet templates
$ rake vagrant:provision[name,provisioner] # Provision vagrant VM.
$ rake vagrant:rebuild[name]               # Rebuild vagrant VM.
```

### 目錄架構

跟上面講的差不多，除了特別把 `role` 跟 `profile` 兩個 modules 從 `private` modules 裡面抽出來到頂層。

關於 `role` 以及 `profile` 可以看我之前的文章 [Roles and Profiles Pattern in Puppet](http://blog.hsatac.net/2014/04/roles-and-profiles-pattern-in-puppet/)。

也算是提供一個這個 pattern 的範例。

```bash
.
├── Gemfile             # Required rubygems, use bundler to install.
├── Puppetfile          # Required puppet modules, use librarian-puppet to install.
├── README.md
├── Rakefile            # Some predefined tasks, to speed up development.
├── Vagrantfile         # Vagrant configuration.
├── hiera.yaml          # Puppet hiera config, only define hierarchy and datadir in this file.
├── docs                # Some documents
├── manifests
│   ├── hieradata         # The actual heirdata stored in this folder.
│   ├── site.pp           # Node definition for production.
│   └── vagrant.pp        # Node definition for local development.
├── private             # Private modules, will be sync into `modules` folder by `librarian-puppet`.
│   ├── common
│   └── users
├── profile             # Profile, abstraction of "Technology stack"
│   ├── files
│   └── manifests
├── role                # Role, abstraction of "What does this server do?"
│   └── manifests
├── spec                # Put test files
└── scripts
    └── upgrade_puppet.sh # Script of upgrading puppet to version 3 on Ubuntu
```

### 在 EC2 上測試

只要稍微設定一下 Vagrantfile，就可以利用 [Vagrant-AWS](https://github.com/mitchellh/vagrant-aws) 直接 deploy 到 AWS EC2 上面測試。