SHELL := /bin/bash

.PHONY: help icons

help:
	@echo "Available targets:"
	@echo "  make icons IMAGE=<path-to-image>   Generate app icons for all supported OS targets"

icons:
	@if [ -z "$(IMAGE)" ]; then \
		echo "Usage: make icons IMAGE=<path-to-image>"; \
		exit 1; \
	fi
	@./scripts/generate_app_icons.sh "$(IMAGE)"
