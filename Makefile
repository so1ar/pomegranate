.PHONY: tests viewcoverage check dep ci

GOLIST=$(shell go list ./...)
GOBIN ?= $(GOPATH)/bin

all: tests check

bin/pmg: pmg/pmg.go
	go build -o $@ $<

dep: $(GOBIN)/dep
	$(GOBIN)/dep ensure -v

tests: dep
	go test .

profile.cov: dep
	go test -coverprofile=$@

viewcoverage: profile.cov 
	go tool cover -html=$<

vet:
	go vet $(GOLIST)

check: $(GOBIN)/megacheck
	$(GOBIN)/megacheck $(GOLIST)

$(GOBIN)/megacheck:
	go get -v -u honnef.co/go/tools/cmd/megacheck

$(GOBIN)/goveralls:
	go get -v -u github.com/mattn/goveralls

$(GOBIN)/dep:
	go get -v -u github.com/golang/dep/cmd/dep

ci: profile.cov vet check $(GOBIN)/goveralls
	$(GOBIN)/goveralls -coverprofile=$< -service=travis-ci
