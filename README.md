# TLS Makefile

Edit the OpenSSL config file `config` and set the subject alternative names in the
subjectAlternativeNames section at the top. At a minumum, the `DNS =` line must be defined.

Also, set the following lines to meaningful values:

```
countryName_default             = US
stateOrProvinceName_default     = California
localityName_default            = Palo Alto
0.organizationName_default      = VMware, Inc
organizationalUnitName_default  = Tanzu Labs
```
**Optionally** Furthur down in the `config` file, uncomment the `commonName_default` line
if you want the deprecated commonName (CN) field included in the subject. By
default, it will reference the `DNS =` line in the subjectAlternativeNames section,
or you can override it.

Finally, and also **optionally** edit the `Makefile` and select your preferred private
key algorithm by commenting-out all of the `KEYCOMMAND=` lines expept for the one
you want.

Happy X.509'ing.
