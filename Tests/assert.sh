# takes a name for snapshot file and string to compare to reference.
# If the snapshot file does not exist, it will be created.
# If the snapshot file does exist, the string will be compared to the snapshot.
# If the string is different, assertion will fail and print the diff.
# For recording new snapshots, use the `SNAPSHOT_RECORD=true` environment variable.
assert_snapshot() {
  local snapshot_name="$1"
  local snapshot_value="$2"
  local snapshot_file="snapshots/$snapshot_name.snapshot"
  mkdir -p snapshots

  if [ "$SNAPSHOT_RECORD" = "true" ]; then
    echo "Recording snapshot $snapshot_name" >&2
    echo "$snapshot_value" > "$snapshot_file"
    return
  fi

  if [ ! -f "$snapshot_file" ]; then
    echo "Snapshot $snapshot_name does not exist. Recording new snapshot." >&2
    echo "$snapshot_value" > "$snapshot_file"
    return
  fi

  local snapshot_diff=$(diff -u "$snapshot_file" <(echo "$snapshot_value"))
  if [ -n "$snapshot_diff" ]; then
    echo "Snapshot $snapshot_name does not match reference." >&2
    echo "$snapshot_diff"
    exit 1
  fi

  echo "Snapshot $snapshot_name matches reference." >&2
}
