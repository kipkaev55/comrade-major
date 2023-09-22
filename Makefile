include .env
export

LOCAL_BIN:=$(CURDIR)/bin
PATH:=$(LOCAL_BIN):$(PATH)

build-image: ### Prepare chromium and caddy image
	@docker build -t jitsi-chromium ./chromium
	@docker build -t jitsi-chromium-caddy ./caddy
.PHONY: build

hash-password: ### make hash password
	@docker run --rm -it jitsi-chromium-caddy caddy hash-password -plaintext '${PASSWORD}'
.PHONY: docker-rm-network

compose-up: ### Some text
	@docker network create jitsi-chromium-net
	@docker volume create jitsi-chromium-data
	@docker run --detach --restart=always --volume=jitsi-chromium-data:/data --net=jitsi-chromium-net --name=jitsi-chromium-app jitsi-chromium
	@docker run --detach --restart=always --volume=jitsi-chromium-data:/data --net=jitsi-chromium-net --name=jitsi-chromium-web --env=APP_USERNAME="${USERNAME}" --env=APP_PASSWORD_HASH="$(shell docker run --rm -it jitsi-chromium-caddy caddy hash-password -plaintext '${PASSWORD}')" --publish=${PORT}:8888 jitsi-chromium-caddy
.PHONY: compose-up

compose-down: ### Some text
	@docker stop jitsi-chromium-app
	@docker stop jitsi-chromium-web
	@docker rm jitsi-chromium-app
	@docker rm jitsi-chromium-web
	@docker volume rm jitsi-chromium-data
	@docker network rm jitsi-chromium-net
.PHONY: compose-up

docker-rm-image: ### remove docker network
	@docker rmi jitsi-chromium
	@docker rmi jitsi-chromium-caddy
.PHONY: docker-rm-image
