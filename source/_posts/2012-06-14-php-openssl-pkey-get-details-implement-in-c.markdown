---
layout: post
title: "php openssl_pkey_get_details implement in c"
date: 2012-06-14 10:49
comments: true
categories: [C, PHP, openssl]
---

It's easy to generate a RSA keypair in PHP, just like this:

```
<?php
// Create the keypair
$res=openssl_pkey_new();

// Get private key
openssl_pkey_export($res, $privkey);

// Get public key
$pubkey=openssl_pkey_get_details($res);
$pubkey=$pubkey["key"];
?>
```

But when it comes to C, it's not that simple.

You might want to use `RSA_generate_key` and then `PEM_write_RSAPublicKey`, but in fact, the output format of PHP's `openssl_pkey_get_details` is not a RSA public key.

If you want to get the same result in C, you have to convert your RSA keypair into EVP keypair.
<!--more-->
Here's my sample script:

{% gist 2909583 %}

You can test it by folloing commands:
`gcc -o key key.c -lssl && ./key`