#!/usr/bin/env bats

# =======================================================================
#
# Testing the project
#
# @see https://github.com/sstephenson/bats
# @see https://blog.engineyard.com/2014/bats-test-command-line-tools
#
# =======================================================================

# Test PHP version
@test "PHP version is ${PHP_VERSION}" {
	result="$(docker run --entrypoint=/bin/sh ${DOCKER_APP_IMAGE_NAME} -c 'php -v 2>&1')"
	[[ "$result" == *"PHP ${PHP_VERSION}"* ]]
}
