MAKEFLAGS += --no-print-directory
EXECUTABLE_NAME := progressline
SWIFT_VERSION := 5.10
ROOT_PATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DOCKER_RUN := docker run --rm --volume $(ROOT_PATH):/workdir --workdir /workdir
ZIP := zip -j
BUILD_FLAGS = --disable-sandbox --configuration release --triple $(TRIPLE)
ifeq ($(TRIPLE), aarch64-unknown-linux-gnu)
	BUILD_FLAGS := $(BUILD_FLAGS) --static-swift-stdlib
	SWIFT := $(DOCKER_RUN) --platform linux/arm64 swift:$(SWIFT_VERSION) swift
	STRIP := $(DOCKER_RUN) --platform linux/arm64 swift:$(SWIFT_VERSION) strip -s
else ifeq ($(TRIPLE), x86_64-unknown-linux-gnu)
	BUILD_FLAGS := $(BUILD_FLAGS) --static-swift-stdlib
	SWIFT := $(DOCKER_RUN) --platform linux/amd64 swift:$(SWIFT_VERSION) swift
	STRIP := $(DOCKER_RUN) --platform linux/amd64 swift:$(SWIFT_VERSION) strip -s
else
	SWIFT := swift
	STRIP := strip -rSTx
endif
EXECUTABLE_PATH = $(shell swift build $(BUILD_FLAGS) --show-bin-path)/$(EXECUTABLE_NAME)
EXECUTABLE_ARCHIVE_PATH = .build/artifacts/$(EXECUTABLE_NAME)-$(TRIPLE).zip

clean:
	@rm -rf .build 2> /dev/null || true
.PHONY: clean

long-running-command:
	@rm -rf .build/apple && swift build -c release --arch x86_64 --arch arm64 2>&1
.PHONY: long-running-command

prepare_release_artifacts: \
prepare_release_artifacts_linux_arm64 \
prepare_release_artifacts_linux_x86_64 \
prepare_release_artifacts_macos_arm64 \
prepare_release_artifacts_macos_x86_64
.PHONY: prepare_release_artifacts

prepare_release_artifacts_linux_arm64:
	@$(MAKE) prepare_release_artifacts_for_triple TRIPLE=aarch64-unknown-linux-gnu
.PHONY: prepare_release_artifacts_linux_arm64

prepare_release_artifacts_linux_x86_64:
	@$(MAKE) prepare_release_artifacts_for_triple TRIPLE=x86_64-unknown-linux-gnu
.PHONY: prepare_release_artifacts_linux_x86_64

prepare_release_artifacts_macos_arm64:
	@$(MAKE) prepare_release_artifacts_for_triple TRIPLE=arm64-apple-macosx
.PHONY: prepare_release_artifacts_macos_arm64

prepare_release_artifacts_macos_x86_64:
	@$(MAKE) prepare_release_artifacts_for_triple TRIPLE=x86_64-apple-macosx
.PHONY: prepare_release_artifacts_macos_x86_64

define relpath
$(shell \
    base="$(1)"; \
    abs="$(2)"; \
    common_part="$$base"; \
    back=""; \
    while [ "$${abs#$$common_part}" = "$$abs" ]; do \
        common_part=$$(dirname "$$common_part"); \
        if [ -z "$$back" ]; then \
            back=".."; \
        else \
            back="../$$back"; \
        fi; \
    done; \
    if [ "$$common_part" = "/" ]; then \
        rel="$$back$${abs#/}"; \
    else \
        forward="$${abs#$$common_part/}"; \
        rel="$$back$$forward"; \
    fi; \
    echo "$$rel" \
)
endef

# use relative path for use with docker container
RELATIVE_EXECUTABLE_PATH = $(call relpath,$(ROOT_PATH),$(EXECUTABLE_PATH))
GREEN := \033[0;32m
NC := \033[0m

prepare_release_artifacts_for_triple:
	$(SWIFT) build $(BUILD_FLAGS) 1> /dev/null
	$(STRIP) $(RELATIVE_EXECUTABLE_PATH)
	@echo "$(GREEN)Built $(EXECUTABLE_PATH)$(NC)"
	zip -j $(EXECUTABLE_ARCHIVE_PATH) $(EXECUTABLE_PATH)
	@echo "$(GREEN)Archived $(EXECUTABLE_ARCHIVE_PATH)$(NC)"
.PHONY: prepare_release_artifacts_for_triple
