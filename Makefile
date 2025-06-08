# ----------------------------------------------------------------------------
# Makefile for running tasks 
# ----------------------------------------------------------------------------

# The "help" target uses grep/awk magic to parse lines that have the format:
#   target: ## Description of the target
# and outputs them as a nicely formatted help menu.
.PHONY: help

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	
download-itop-latest: ## Download latest iTop release and save filename
	mkdir -p downloads/itop config/var
	cd downloads/itop && \
	filename=$$(curl -sI -L "https://sourceforge.net/projects/itop/files/latest/download" \
		| grep -i 'Content-Disposition:' \
		| sed -n 's/.*filename="\([^"]*\)".*/\1/p'); \
	echo "$$filename" > ../../config/var/itop-latest.txt; \
	if [ -f "$$filename" ]; then \
		echo "Already downloaded: $$filename"; \
	else \
		echo "Downloading $$filename..."; \
		wget -O "$$filename" "https://sourceforge.net/projects/itop/files/latest/download"; \
	fi

unpack-itop-latest: ## Unpack downloaded iTop archive
	@test -f config/var/itop-latest.txt || (echo "No file found in config/var/itop-latest.txt. Run 'make download-itop-latest' first." && exit 1)
	@filename=$$(cat config/var/itop-latest.txt); \
	echo "Unzipping downloads/itop/$$filename..."; \
	unzip -o downloads/itop/$$filename -d work/itop

deploy-itop-to-container: ## Copy ./work/itop/web contents into itop-web:/app (overwrites container state)
	docker exec itop-web rm -rf /app/*
	docker cp work/itop/web/. itop-web:/app/



