.PHONY: all cpu gpu clean

# Default target
all: gpu

# Remove existing container if it exists
clean:
	docker rm -f fhiaims_build 2>/dev/null || true

check:
	# Check to see if FHIaims folder exists, and if it does, print a message
	if [ -d "FHIaims" ]; then \
		echo "./FHIaims folder already exists, aborting out of precaution"; \
		exit 1; \
	fi

	# Check to see if docker is installed
	if ! docker info > /dev/null 2>&1; then \
		echo "Docker is not installed"; \
		exit 1; \
	fi

# CPU build target
cpu: clean check
	$(eval SSH_KEY := $(shell if [ -f "${HOME}/.ssh/id_ed25519" ]; then echo "id_ed25519"; elif [ -f "${HOME}/.ssh/id_rsa" ]; then echo "id_rsa"; fi))
	@if [ -z "$(SSH_KEY)" ]; then echo "No SSH key found (checked id_ed25519 and id_rsa)"; exit 1; fi
	docker build -t fhiaims-builder .
	docker run -it \
		-v $(HOME)/.ssh/$(SSH_KEY):/root/.ssh/$(SSH_KEY) \
		-v $(HOME)/.ssh/$(SSH_KEY).pub:/root/.ssh/$(SSH_KEY).pub \
		-v $(PWD):/workspaces/fhi-aims-build \
		--name fhiaims_build \
		-e GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
		fhiaims-builder \
		/bin/bash -c "mkdir -p /root/.ssh && chmod 600 /root/.ssh/$(SSH_KEY) && /workspaces/fhi-aims-build/buildscript"
	docker rm fhiaims_build

# GPU build target
gpu: clean check
	$(eval SSH_KEY := $(shell if [ -f "${HOME}/.ssh/id_ed25519" ]; then echo "id_ed25519"; elif [ -f "${HOME}/.ssh/id_rsa" ]; then echo "id_rsa"; fi))
	@if [ -z "$(SSH_KEY)" ]; then echo "No SSH key found (checked id_ed25519 and id_rsa)"; exit 1; fi
	docker build -t fhiaims-builder .
	docker run --gpus all -it \
		-v $(HOME)/.ssh/$(SSH_KEY):/root/.ssh/$(SSH_KEY) \
		-v $(HOME)/.ssh/$(SSH_KEY).pub:/root/.ssh/$(SSH_KEY).pub \
		-v $(PWD):/workspaces/fhi-aims-build \
		--name fhiaims_build \
		-e GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
		fhiaims-builder \
		/bin/bash -c "mkdir -p /root/.ssh && chmod 600 /root/.ssh/$(SSH_KEY) && /workspaces/fhi-aims-build/buildscript"
	docker rm fhiaims_build
