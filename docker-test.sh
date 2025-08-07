#!/bin/bash

# Test script for multiple Ruby versions and platforms using Docker

set -e

echo "🐳 Testing ruby-simpleble with Docker..."

# Ruby versions to test
RUBY_VERSIONS=("2.7" "3.0" "3.1" "3.2" "3.3")

# Test each Ruby version
for version in "${RUBY_VERSIONS[@]}"; do
    echo "📦 Testing Ruby ${version}..."
    
    docker build \
        --build-arg RUBY_VERSION=${version} \
        -f Dockerfile.test \
        -t ruby-simpleble-test:${version} \
        .
    
    echo "🧪 Running tests for Ruby ${version}..."
    docker run --rm ruby-simpleble-test:${version}
    
    echo "✅ Ruby ${version} tests completed"
    echo "----------------------------------------"
done

echo "🎉 All Docker tests completed!"