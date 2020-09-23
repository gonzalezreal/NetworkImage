DESTINATION_MAC = platform=macOS
DESTINATION_IOS = platform=iOS Simulator,name=iPhone 8
DESTINATION_TVOS = platform=tvOS Simulator,name=Apple TV
DESTINATION_WATCHOS = platform=watchOS Simulator,name=Apple Watch Series 4 - 40mm

default: test

test:
	xcodebuild test \
			-scheme NetworkImage \
			-destination '$(DESTINATION_MAC)'
	xcodebuild test \
			-scheme NetworkImage \
			-destination '$(DESTINATION_IOS)'
	xcodebuild test \
			-scheme NetworkImage \
			-destination '$(DESTINATION_TVOS)'
	xcodebuild \
			-scheme NetworkImage_watchOS \
			-destination '$(DESTINATION_WATCHOS)'
