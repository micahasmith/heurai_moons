PROJECT := HeuraiMoons.xcodeproj
SCHEME := HeuraiMoons
CONFIGURATION := Debug
SDKROOT := $(shell xcrun --show-sdk-path --sdk macosx)

.PHONY: help setup open build regenerate run-first-launch typecheck clean reset-derived-data reset-previews

help:
	@printf "%s\n" \
		"Available targets:" \
		"  make setup           Generate the Xcode project with XcodeGen" \
		"  make regenerate      Regenerate the Xcode project from project.yml" \
		"  make open            Open the Xcode project" \
		"  make build           Build the macOS app target with xcodebuild" \
		"  make run-first-launch Run Xcode first-launch setup (may prompt for sudo)" \
		"  make typecheck       Swift type-check the macOS app sources" \
		"  make clean           Remove generated build artifacts" \
		"  make reset-derived-data Remove this project's Xcode DerivedData folder" \
		"  make reset-previews  Remove Xcode preview cache for a clean widget canvas reload"

setup:
	xcodegen generate

regenerate: setup

open:
	open $(PROJECT)

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIGURATION) build

run-first-launch:
	sudo xcodebuild -runFirstLaunch

typecheck:
	xcrun swiftc -typecheck -sdk "$(SDKROOT)" -target arm64-apple-macos14.0 Shared/Sources/*.swift App/Sources/*.swift

clean:
	rm -rf build DerivedData

reset-derived-data:
	rm -rf ~/Library/Developer/Xcode/DerivedData/HeuraiMoons-*

reset-previews:
	rm -rf ~/Library/Developer/Xcode/UserData/Previews
