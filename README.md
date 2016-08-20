# CloudFlare's PKI/TLS toolkit - Dockerized

**Forked from:** `fabric8io/docker-cfssl`

This is a dockerized version of https://github.com/cloudflare/cfssl.

```
$ docker run -p 443:8443 -e CFSSL_CA_HOST=ca.qa.rnatest.brightcove.com ankurcha/docker-cfssl
```

This will generate a key & certificate. To provide these, mount them at
`/etc/cfssl/ca.pem` & `/etc/cfssl/ca-key.pem` respectively.

Volume should be provided at `/etc/cfssl`.

The following environment variables can be used to configure CFSSL:

* `CFSSL_CA_HOST` - CA hostname. Default: `example.localnet`
* `CFSSL_CA_ALGO` - Algorithm used to generate CA key. Default: `rsa`
* `CFSSL_CA_KEY_SIZE` - CA key length. Default: `2048`
* `CFSSL_CA_ORGANIZATION` - `O` part of CA certificate name. Default: `Brightcove, Inc.`
* `CFSSL_CA_ORGANIZATIONAL_UNIT` - `OU` part og CA certificate name. Default: `RnA Internal Certificate Authority`
* `CFSSL_CA_POLICY_FILE` - CA policy file (generated or provided). Default: `/etc/cfssl/ca_policy.json`
