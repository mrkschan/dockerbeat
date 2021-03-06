GODEP=$(GOPATH)/bin/godep
PREFIX?=/build

GOFILES = $(shell find . -type f -name '*.go')
dockerbeat: $(GOFILES)
	# first make sure we have godep
	go get github.com/tools/godep
	$(GODEP) go build

.PHONY: getdeps
getdeps:
	go get -t -u -f

.PHONY: test
test:
	$(GODEP) go test ./...

.PHONY: updatedeps
updatedeps:
	$(GODEP) update ...

.PHONY: dockermake
dockermake:
	docker run --rm \
		-v ${PWD}:/usr/src/dockerbeat \
		-w /usr/src/dockerbeat \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		golang:1.5.1 /bin/bash -c "make && chown $$(id -ru):$$(id -rg) dockerbeat"

.PHONY: install_cfg
install_cfg:
	cp etc/dockerbeat.yml $(PREFIX)/dockerbeat-linux.yml
	cp etc/dockerbeat.template.json $(PREFIX)/dockerbeat.template.json
	# darwin
	cp etc/dockerbeat.yml $(PREFIX)/dockerbeat-darwin.yml
	# win
	cp etc/dockerbeat.yml $(PREFIX)/dockerbeat-win.yml

.PHONY: gofmt
gofmt:
	go fmt ./...

.PHONY: cover
cover:
	# gotestcover is needed to fetch coverage for multiple packages
	go get github.com/pierrre/gotestcover
	GOPATH=$(shell $(GODEP) path):$(GOPATH) $(GOPATH)/bin/gotestcover -coverprofile=profile.cov -covermode=count github.com/ingensi/dockerbeat/...
	mkdir -p cover
	$(GODEP) go tool cover -html=profile.cov -o cover/coverage.html

.PHONY: clean
clean:
	rm -r cover || true
	rm profile.cov || true
	rm dockerbeat || true
