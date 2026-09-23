# safe_cleanup.sh

A defensive Bash script that safely deletes files older than 1 day from a given directory, with full input validation and a dry-run mode for safe previewing.

## Why this exists

A practical example of defensive Bash scripting for DevOps automation: input validation, safe filename handling, guaranteed cleanup on failure, and a non-destructive preview mode — patterns commonly needed for cron jobs, log rotation, or cache cleanup on Linux servers.

## Usage

```bash
./safe_cleanup.sh <directory> [--dry-run]
```

Examples:

```bash
./safe_cleanup.sh /tmp/app_cache              # deletes old files
./safe_cleanup.sh /tmp/app_cache --dry-run    # preview only, no deletion
```

## Output

```bash
$ ./safe_cleanup.sh /tmp/app_cache
/tmp/app_cache/old_log.txt
/tmp/app_cache/cache_2024.tmp
[DELETED] 2 files were removed.

$ ./safe_cleanup.sh /tmp/app_cache --dry-run
[DRY-RUN] Would delete: 2 files.
/tmp/app_cache/old_log.txt
/tmp/app_cache/cache_2024.tmp
```

## Features

- `set -euo pipefail` — stops on any unhandled error, undeclared variable, or pipe failure.
- Full input validation before any variable is used (argument count, directory existence/permissions/emptiness, valid flag).
- Safe filename handling via `find -print0` + `mapfile -d ''`, so paths with spaces never break.
- Guaranteed cleanup with `trap` — a temp log file is always removed on exit, with a warning printed if the script failed before finishing.
- Dry-run mode to preview deletions with zero risk.

## Requirements

- Bash 4+
- Linux/Unix (`find`, `mktemp`)
