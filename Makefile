build:
	docker build -t azp-agent:dev .

run:
	docker run -it --rm --name=azp-agent azp-agent:dev bash

push:
	sh docker-push.sh

clean:
	docker rmi azp-agent-autoscaler:dev
