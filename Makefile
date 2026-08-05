.PHONY: *

SHELL = /bin/sh

CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)

#
# If the English manual or build tools exist as siblings, use those local
# checkouts instead of the copies bundled in the image.
#

PATHS := -v ${PWD}:/var/www/extensions
ifneq ($(wildcard ../en/manual.xml),)
	PATHS += -v ${PWD}/../en:/var/www/en
else ifneq ($(wildcard ../doc-en/manual.xml),)
	PATHS += -v ${PWD}/../doc-en:/var/www/en
endif
ifneq ($(wildcard ../doc-base/LICENSE),)
	PATHS += -v ${PWD}/../doc-base:/var/www/doc-base
endif
ifneq ($(wildcard ../phd/LICENSE),)
	PATHS += -v ${PWD}/../phd:/var/www/phd
endif

xhtml: temp/.dockerbuilt
	docker run --rm ${PATHS} -w /var/www -u ${CURRENT_UID}:${CURRENT_GID} php/doc-extensions

php: temp/.dockerbuilt
	docker run --rm ${PATHS} -w /var/www -u ${CURRENT_UID}:${CURRENT_GID} \
		-e FORMAT=php php/doc-extensions

build: temp/.dockerbuilt

temp/.dockerbuilt: .docker/Dockerfile
	docker build \
		--build-arg UID=${CURRENT_UID} --build-arg GID=${CURRENT_GID} \
		.docker -t php/doc-extensions
	mkdir -p temp && touch temp/.dockerbuilt
