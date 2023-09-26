include .env
export

LOCAL_BIN:=$(CURDIR)/bin
PATH:=$(LOCAL_BIN):$(PATH)

build-image: ### Prepare applications and caddy image
	@docker build -t jitsi-x11 ./x11
	@docker build -t jitsi-caddy ./caddy
.PHONY: build

hash-password: ### make hash password
	@docker run --rm -it jitsi-caddy caddy hash-password -plaintext '${PASSWORD}'
.PHONY: docker-rm-network

compose-up: ### Some text
	@docker network create jitsi-x11-net
	@docker volume create jitsi-x11-data
	@docker run --detach --restart=always --volume=jitsi-x11-data:/data --net=jitsi-x11-net --name=jitsi-x11-app --cap-add=SYS_ADMIN jitsi-x11
	@docker run --detach --restart=always --volume=jitsi-x11-data:/data --net=jitsi-x11-net --name=jitsi-x11-web --env=APP_USERNAME="${USERNAME}" --env=APP_PASSWORD_HASH="$(shell docker run --rm -it jitsi-caddy caddy hash-password -plaintext '${PASSWORD}')" --publish=${PORT}:8888 jitsi-caddy
.PHONY: compose-up

compose-down: ### Some text
	@docker stop jitsi-x11-app
	@docker stop jitsi-x11-web
	@docker rm jitsi-x11-app
	@docker rm jitsi-x11-web
	@docker volume rm jitsi-x11-data
	@docker network rm jitsi-x11-net
.PHONY: compose-up

docker-rm-image: ### remove docker network
	@docker rmi jitsi-x11
	@docker rmi jitsi-caddy
.PHONY: docker-rm-image
