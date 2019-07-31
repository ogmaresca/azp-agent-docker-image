build:
	./docker-build.sh

run:
	docker run -it --rm --name=azp-agent azp-agent:dev bash

push:
	./docker-push.sh

clean:
	docker rmi azp-agent:dev
