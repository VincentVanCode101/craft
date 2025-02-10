- Decide on:
    - Controlling the error-flow(use exit in function and trap EXIT with custom cleanup function, or use returns in functions and trap ERR)
    - Make in docker (should I remove Make and substitute the fucntionality with bash scripts?)

- Get Esa to do styling with ncurs

- BATS testing in a docker container
    - add check in craft script for correct bash version

- How to sem-ver?
    - How to check for new updates
    - How to prompt user to update repo (update script?)

- Provide standard flags (--version, --verbose, maybe --dry-run)

- use wget when curl is unavailable

- test tool on macOS

- Exit Codes and Standardization:
```bash
readonly EXIT_SUCCESS=0
readonly EXIT_INVALID_ARGS=1
readonly EXIT_NETWORK_ERROR=2
readonly EXIT_RUNTIME_ERROR=3
```

- complete TODOs