---
layout: post
title: "Roles and Profiles Pattern in Puppet"
date: 2014-04-12 14:04
comments: true
categories: [Puppet]
---

一開始寫 Puppet 就是 node definition 直接寫寫寫...後來就會開始把重複的 resource, file 等等拆成 modules...。不過當機器越來越多，發現還是有許多重複的地方，例如有好多台 web server, 但是他們有些又有些許的不同...。
<!-- more -->
## Original Style

先看看傳統的寫法：

```
node web {
	include users
	include nginx
	include rails
}

node worker {
	include users
	include rails
	include redis
}

node db {
	include users
	include mysql
}

node web-qa {
	include users
	include nginx
	include rails
	include mysql
	include redis
}
```

四個看起來還好，但是當機器越來越多的時候，就會感到難以維護了。

## Roles and Profiles Pattern

> All problems in computer science can be solved by another level of indirection.

所有電腦科學領域的問題都可以用抽象化來解決(除了抽象太多層以外)，以上的問題我們可以用現在常見的 "Roles and Profiles Pattern" 來做抽象。

## Role

Role 很好理解，顧名思義就是「扮演的角色」，以上面的例子我們就有 web, db, worker，web 可能又分成 production 環境和 QA 環境。

用這個思路來整理 node 會變成這樣：

```
node web {
	include role::web::production
}

node worker {
	include role::worker
}

node db {
	include role::db
}

node web-qa {
	include role::web::qa
}
```

Role 本身大概會長這樣：

```
class role { 
  include profile::base
}
 
class role::web inherits role { 
  include profile::nginx
}
 
class role::web::production inherits role::web { 
  include profile::nginx::production
}

class role::web::qa inherits role::web { 
  include profile::nginx::qa
  include profile::db
  include profile::worker
}
 
class role::db inherits role { 
  include profile::mysql
}
 
class role::worker inherits role { 
  include profile::worker
}
```

## Profile

Profile 則是用來抽象化「一組服務、設定」的。看上面 Role 的部份應該有點感覺了：

```
class profile::base {
	include users
}

class profile::web {
	include nginx
	include rails
}

class profile::web::production inherits profile::web {
	::nginx::file { 'production.conf':
      content => ...,
  }
}

class profile::web::qa inherits profile::web {
	::nginx::file { 'qa.conf':
      content => ...,
  }
}

class profile::db inherits { 
	include profile::mysql
}

class profile::worker {}
	include rails
	include redis
}
```

這樣就可以把重複的程式碼減少，同時又保留彈性。

## Tips

* 一個 node 只 include *一個* role。如果這兩個 role 很像，但又有些微不同，那就是一個新 role。
* 一個 role include 一個或多個 profile，而且 *只能 include profile* 。

## Further Reading

更多詳細細節、優缺點以及不同的設計方式可以參考以下的幾篇連結：

* [Designing Puppet – Roles and Profiles](http://www.craigdunn.org/2012/05/239/)
* [Designing Puppet: Roles/Profiles Pattern](http://www.slideshare.net/PuppetLabs/roles-talk)
* [Building a Functional Puppet Workflow Part 2: Roles and Profiles](http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/)
* [Configuration Management as Legos](http://sysadvent.blogspot.tw/2012/12/day-13-configuration-management-as-legos.html)