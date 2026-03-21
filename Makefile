# To see how to drive this makefile use:
#
#   % make help

# The following values can be changed here, or passed on the command line.
SWIFT_OPENAPI_GENERATOR_GIT_URL ?= https://github.com/apple/swift-openapi-generator
SWIFT_OPENAPI_GENERATOR_GIT_TAG ?= 1.10.2
SWIFT_OPENAPI_GENERATOR_CLONE_DIR ?= $(CURRENT_MAKEFILE_DIR)/.swift-openapi-generator
SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION ?= debug
OPENAPI_YAML_PATH ?= $(CURRENT_MAKEFILE_DIR)/openapi.yaml
OPENAPI_GENERATOR_CONFIG_PATH ?= $(CURRENT_MAKEFILE_DIR)/openapi-generator-config.yaml
OUTPUT_DIRECTORY ?= $(CURRENT_MAKEFILE_DIR)/Sources/FreeAgentAPI/Generated
OPENAPI_SOURCE_DIR ?= $(CURRENT_MAKEFILE_DIR)/openapi
OPENAPI_SOURCE_ROOT ?= $(OPENAPI_SOURCE_DIR)/openapi.yaml

# Derived values (don't change these).
CURRENT_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(CURRENT_MAKEFILE_PATH)))
SWIFT_OPENAPI_GENERATOR_BIN := $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)/.build/$(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)/swift-openapi-generator
OPENAPI_BUNDLER_BIN := $(CURRENT_MAKEFILE_DIR)/.build/debug/OpenAPIBundler
OPENAPI_SOURCE_FILES := $(shell find $(OPENAPI_SOURCE_DIR) -name '*.yaml' 2>/dev/null)

# If no target is specified, display help
.DEFAULT_GOAL := help

help:  # Display this help.
	@-+echo "Run make with one of the following targets:"
	@-+echo
	@-+grep -Eh "^[a-z-]+:.*#" $(CURRENT_MAKEFILE_PATH) | sed -E 's/^(.*:)(.*#+)(.*)/  \1 @@@ \3 /' | column -t -s "@@@"
	@-+echo
	@-+echo "The following options can be overriden on the command line:"
	@-+echo
	@-+echo "  SWIFT_OPENAPI_GENERATOR_GIT_URL (e.g. https://github.com/apple/swift-openapi-generator)"
	@-+echo "  SWIFT_OPENAPI_GENERATOR_GIT_TAG (e.g. 1.0.0)"
	@-+echo "  SWIFT_OPENAPI_GENERATOR_CLONE_DIR (e.g. .swift-openapi-generator)"
	@-+echo "  SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION (e.g. release)"
	@-+echo "  OPENAPI_YAML_PATH (e.g. openapi.yaml)"
	@-+echo "  OPENAPI_GENERATOR_CONFIG_PATH (e.g. openapi-generator-config.yaml)"
	@-+echo "  OUTPUT_DIRECTORY (e.g. Sources/FreeAgentAPI/Generated)"

bundle: $(OPENAPI_BUNDLER_BIN) $(OPENAPI_SOURCE_FILES)  # Bundle split OpenAPI files into a single openapi.yaml.
	$(OPENAPI_BUNDLER_BIN) "$(OPENAPI_SOURCE_ROOT)" "$(OPENAPI_YAML_PATH)"

generate: bundle $(SWIFT_OPENAPI_GENERATOR_BIN) $(OPENAPI_GENERATOR_CONFIG_PATH) $(OUTPUT_DIRECTORY)  # Bundle and generate Swift sources from OpenAPI spec.
	$(SWIFT_OPENAPI_GENERATOR_BIN) generate \
		--config "$(OPENAPI_GENERATOR_CONFIG_PATH)" \
		--output-directory "$(OUTPUT_DIRECTORY)" \
		"$(OPENAPI_YAML_PATH)"

build:  # Runs swift build.
	swift build

lint:  # Run SwiftLint on the project.
	swiftlint

format:  # Run SwiftFormat on the project.
	swiftformat .

clean:  # Delete the output directory used for generated sources.
	@echo 'Delete entire directory: $(OUTPUT_DIRECTORY)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(OUTPUT_DIRECTORY)"

clean-all: clean  # Clean everything, including the checkout of swift-openapi-generator.
	@echo 'Delete checkout of swift-openapi-generator $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)? [y/N] ' && read ans && [ $${ans:-N} = y ] || (echo "Aborted"; exit 1)
	rm -rf "$(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)"


dump:  # Dump all derived values used by the Makefile.
	@echo "CURRENT_MAKEFILE_PATH = $(CURRENT_MAKEFILE_PATH)"
	@echo "CURRENT_MAKEFILE_DIR = $(CURRENT_MAKEFILE_DIR)"
	@echo "SWIFT_OPENAPI_GENERATOR_GIT_URL = $(SWIFT_OPENAPI_GENERATOR_GIT_URL)"
	@echo "SWIFT_OPENAPI_GENERATOR_GIT_TAG = $(SWIFT_OPENAPI_GENERATOR_GIT_TAG)"
	@echo "SWIFT_OPENAPI_GENERATOR_CLONE_DIR = $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)"
	@echo "SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION = $(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)"
	@echo "SWIFT_OPENAPI_GENERATOR_BIN = $(SWIFT_OPENAPI_GENERATOR_BIN)"
	@echo "OPENAPI_YAML_PATH = $(OPENAPI_YAML_PATH)"
	@echo "OPENAPI_GENERATOR_CONFIG_PATH = $(OPENAPI_GENERATOR_CONFIG_PATH)"
	@echo "OUTPUT_DIRECTORY = $(OUTPUT_DIRECTORY)"
	@echo "OPENAPI_SOURCE_DIR = $(OPENAPI_SOURCE_DIR)"
	@echo "OPENAPI_SOURCE_ROOT = $(OPENAPI_SOURCE_ROOT)"

$(SWIFT_OPENAPI_GENERATOR_CLONE_DIR):
	git \
		-c advice.detachedHead=false \
		clone \
		--branch "$(SWIFT_OPENAPI_GENERATOR_GIT_TAG)" \
		--depth 1 \
		"$(SWIFT_OPENAPI_GENERATOR_GIT_URL)" \
		$@

$(SWIFT_OPENAPI_GENERATOR_BIN): $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)
	swift \
		build \
		--package-path "$(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)" \
		--configuration "$(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)" \
		--product swift-openapi-generator

$(OPENAPI_BUNDLER_BIN): $(wildcard $(CURRENT_MAKEFILE_DIR)/Sources/OpenAPIBundler/*.swift) $(CURRENT_MAKEFILE_DIR)/Package.swift
	swift build --product OpenAPIBundler

$(OUTPUT_DIRECTORY):
	mkdir -p "$@"

.PHONY: help bundle generate build lint format clean clean-all dump
