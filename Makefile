# Disable make's implicit rules, which are not useful for golang, and
# slow down the build considerably.

VPATH=bin:l4lb:pkg/spartan

# Default go OS to linux
export GOOS?=linux

# Set $GOPATH to a local directory so that we are not influenced by
# the hierarchical structure of an existing $GOPATH directory.
export GOPATH=$(shell pwd)/gopath

#dcos-l4lb
L4LB=github.com/dcos/dcos-cni-plugins/l4lb
L4LB_SRC=$(wildcard l4lb/*.go) $(wildcard pkg/spartan/*.go)

PLUGINS=dcos-l4lb

.PHONY: all plugin
default: all

.PHONY: clean
clean:
	rm -rf vendor bin gopath

gopath:
	mkdir -p gopath/src/github.com/dcos
	ln -s `pwd` gopath/src/github.com/dcos/dcos-cni-plugins

# To update upstream dependencies, delete the glide.lock file first.
# Use this to populate the vendor directory after checking out the
# repository.
vendor: glide.yaml
	echo $(GOPATH)
	glide install -strip-vendor

dcos-l4lb:$(L4LB_SRC)
	echo "GOPATH:" $(GOPATH)
	mkdir -p `pwd`/bin
	go build -v -o `pwd`/bin/$@ $(L4LB)

plugin: gopath vendor $(PLUGINS)

all: plugin

