.SILENT :
.PHONY : docker-gen clean fmt

TAG:=`git describe --tags`
LDFLAGS:=-X main.buildVersion=$(TAG)

all: docker-gen

docker-gen:
	echo "Building docker-gen"
	go build -ldflags "$(LDFLAGS)" ./cmd/docker-gen

dist-clean:
	rm -rf dist
	rm -f docker-gen-linux-*.tar.gz

dist: dist-clean
	mkdir -p dist/linux/arm64 && GOOS=linux GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o dist/linux/arm64/docker-gen ./cmd/docker-gen


release: dist
	glock sync -n < GLOCKFILE
	tar -cvzf docker-gen-linux-arm64-$(TAG).tar.gz -C dist/linux/arm64 docker-gen

get-deps:
	go get github.com/robfig/glock
	glock sync -n < GLOCKFILE

check-gofmt:
	if [ -n "$(shell gofmt -l .)" ]; then \
		echo 1>&2 'The following files need to be formatted:'; \
		gofmt -l .; \
		exit 1; \
	fi

test:
	go test
