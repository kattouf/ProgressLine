#!/usr/bin/env bash

set -eo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

source "$TESTS_DIR/assert.sh"

# Parse arg: <executable path>
executable_path="$1"
if [ -z "$executable_path" ]; then
  echo "Usage: $0 <executable path>"
  exit 1
fi

# Prepare test data

test_data_producer_config="{
  \"chunk_count\": 30,
  \"chunk_size\": 3,
  \"write_delay\": 10,
}"
test_data_producer_config_file="/tmp/progressline_test_data_producer_config.json"
echo "$test_data_producer_config" > "$test_data_producer_config_file"

# warmup test data producer
swift "$TESTS_DIR"/test_data_producer.swift $test_data_producer_config_file > /dev/null

generate_test_output="swift $TESTS_DIR/test_data_producer.swift $test_data_producer_config_file"

# Test default mode

output=$($generate_test_output | "$executable_path" --test-mode)
assert_snapshot "default" "$output"

# Test static text mode

output=$($generate_test_output | "$executable_path" --test-mode --static-text "Static text")
assert_snapshot "static_text" "$output"

# Test default mode with save original log

output=$($generate_test_output | "$executable_path" --test-mode --original-log-path /tmp/progressline_test_original_log.txt)
assert_snapshot "default_with_original_log" "$output"
assert_snapshot "default_with_original_log_original_log" "$(cat /tmp/progressline_test_original_log.txt)"
rm /tmp/progressline_test_original_log.txt

# Test log matches

output=$($generate_test_output | "$executable_path" --test-mode --log-matches "Chunk number: \d+[1-5]{1}")
assert_snapshot "log_matches" "$output"

# Test log all

output=$($generate_test_output | "$executable_path" --test-mode --log-all)
assert_snapshot "log_all" "$output"
