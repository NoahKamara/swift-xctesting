#
#swift package --allow-writing-to-directory ./docs \
#    generate-documentation --target XCTesting --output-path ./docs


swift package --allow-writing-to-directory ./docs \
    generate-documentation \
        --target XCTesting \
        --disable-indexing \
        --exclude-extended-types \
        --output-path ./docs \
        --transform-for-static-hosting \
        --hosting-base-path swift-xctesting
