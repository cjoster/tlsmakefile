# Set the PRIMARY hostname of the endpoint here. This makefile will parse the DNS subjectAltName
# "DNS" subjectAltName out of the config file if it exists, by default.
# ENDPOINT=test.server.example.com

# These this is how you select which key algorithm you want to use.
# Un-comment only one, or else the last uncommented line takes precedence.
KEYCOMMAND=openssl ecparam -name prime256v1 -genkey | openssl ec 2>/dev/null	# ECC with secp256 curve 
#KEYCOMMAND=openssl genpkey -algorithm ed25519                               	# ECC with ed25519 curve, not supported on RHEL7
#KEYCOMMAND=openssl dsaparam -genkey 1024 | openssl dsa 2>/dev/null          	# DSA with 1024 bit key
#KEYCOMMAND=openssl genrsa 2048                                              	# RSA with 2048 bit key
#KEYCOMMAND=openssl genrsa 4096                                              	# RSA with 2048 bit key

# These variables should not be modified unless you know
# what you are doing.
KEYFILE=$(ENDPOINT).key
CSRFILE=$(ENDPOINT).csr

# If ENDPOINT is not defined or otherwise empty, parse out the DNS.1subjectAltName from the config file
ifeq ($(strip $(ENDPOINT)),)
ENDPOINT=$(shell cat config | awk 'BEGIN{o=0}o==1{print}$$1~/\s*\[/{if($$1~/subjectAlternativeName/ || $$2~/subjectAlternativeName/){o=1}else{exit 1}}' | grep '^[[:space:]]*DNS[[:space:]]*=' | head -n 1 | sed 's/.*=[[:space:]]//; s/#.*//; s/[[:space:]]*$$//; s/*/wildcard/g')
endif

ifeq ($(strip $(ENDPOINT)),)
.PHONY: all err
%: err
	exit 1
err:
	@echo "*** ERROR *** Please set the DNS.1 subject alternative name in \"config\", or alternatively, the ENDPOINT variable at the top of Makefile."; exit 1
else

.PHONY: all csr selfsigned clean key rekey destroy
all: csr 

selfsigned: csr

csr: key
	@[ -s "$(CSRFILE)" ] || openssl req -new -key "$(KEYFILE)" -config config -batch -out "$(CSRFILE)" || { rm -f "$(CSRFILE)"; echo "*** FATAL *** CSR not created."; exit 1; }
	@openssl req -in "$(CSRFILE)" -text

ifndef KEYCOMMAND
key:
	@echo "*** ERROR *** Please uncomment one of the KEYCOMMAND directives in Makefile to use this."; exit 1
else
key:
	@[ -f "$(KEYFILE)" ] && echo "Keyfile \"$(KEYFILE)\" exists. Not overwriting." || \
		{ $(KEYCOMMAND) > "$(KEYFILE)" && [ -s "$(KEYFILE)" ] && echo "Key generated and saved as \"$(KEYFILE)\"." || \
		{ echo "Key not created successfully. Bailing out."; rm -f "$(KEYFILE)"; exit 1;}; } 
endif

clean:
	rm -f *.csr

destroy: clean
	rm -f *.key *.crt

rekey: destroy csr
endif
