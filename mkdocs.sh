
swift package --allow-writing-to-directory ./Documentation.doccarchive \
    generate-documentation --target XCTesting --output-path ./Documentation.doccarchive \
    --transform-for-static-hosting --hosting-base-path XCTesting
