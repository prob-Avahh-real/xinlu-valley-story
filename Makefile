.PHONY: help install gen test test-coverage analyze format clean build-android build-ios run

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	flutter pub get

gen: ## Run code generation
	dart run build_runner build --delete-conflicting-outputs

test: ## Run unit tests
	flutter test

test-coverage: ## Run tests with coverage
	flutter test --coverage

analyze: ## Run static analysis
	flutter analyze

format: ## Format code
	dart format .

format-check: ## Check formatting
	dart format --set-exit-if-changed .

clean: ## Clean build artifacts
	flutter clean && rm -rf build/ .dart_tool/ coverage/

build-android: ## Build Android APK
	flutter build apk --release

build-ios: ## Build iOS app
	flutter build ios --release --no-codesign

pub-upgrade: ## Upgrade dependencies
	flutter pub upgrade

run: ## Run in debug mode
	flutter run
