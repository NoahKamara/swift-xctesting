#
#swift package --allow-writing-to-directory ./docs \
#    generate-documentation --target XCTesting --output-path ./docs

swift package --disable-sandbox \
    preview-documentation \
        --target XCTesting \
        --disable-indexing \
        --exclude-extended-types \
        --transform-for-static-hosting \
        --output-path ./Documentation.doccarchive
