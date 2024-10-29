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

# CPU build target
cpu: clean check
	docker build -t fhiaims-builder .
	docker run -it \
		-v $(HOME)/.ssh:/root/.ssh:ro \
		-v $(PWD):/workspaces/fhi-aims-build \
		--name fhiaims_build \
		fhiaims-builder \
		/bin/bash -c "/workspaces/fhi-aims-build/build.sh"
	docker rm fhiaims_build

# GPU build target
gpu: clean check
	docker build -t fhiaims-builder .
	docker run --gpus all -it \
		-v $(HOME)/.ssh:/root/.ssh:ro \
		-v $(PWD):/workspaces/fhi-aims-build \
		--name fhiaims_build \
		fhiaims-builder \
		/bin/bash -c "/workspaces/fhi-aims-build/build.sh"
	docker rm fhiaims_build
