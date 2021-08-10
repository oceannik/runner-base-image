.PHONY:
	build
	run
	run-bash
	install
	fetch-build-dependencies
	clean

build:
	docker build -t oceannik/runner-base-image -f Containerfile .

run:
	docker run \
		-e OCEANNIK_SERVICE_CONFIG_PATH=example-project/oceannik.yml \
		-v ~/.oceannik/certs/oceannik_runner:/usr/oceannik/user-certs:ro \
		oceannik/runner-base-image

run-bash:
	docker run -it oceannik/runner-base-image bash

install:
	mkdir -p build-dependencies/bin build-dependencies/src

fetch-build-dependencies:
	git clone git@github.com:oceannik/deployment-strategies.git build-dependencies/src/deployment-strategies

clean:
	rm -r build-dependencies/
