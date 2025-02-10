- [ ] decide on:
    - [x] controlling the error-flow(use exit in function and trap EXIT with custom cleanup function, or use returns in functions and trap ERR)
    - [ ] `make` in docker (should I remove Make and substitute the fucntionality with bash scripts?)

- [ ] get Esa to do styling with ncurs

- [ ] setup docker container
    - [ ] add BATS testing
        - [ ] add check in craft script for correct bash version
    - [x] add automatic shell checks

- [ ] how to sem-ver?
    - [x] how to check for new updates
    - [x] how to prompt user to update repo (update script?)

- [ ] provide standard flags (--version, --verbose, maybe --dry-run)

- [ ] use wget when curl is unavailable

- [ ] test tool on macOS

- [ ] use standardized exit codes
```bash
readonly EXIT_SUCCESS=0
readonly EXIT_INVALID_ARGS=1
readonly EXIT_NETWORK_ERROR=2
readonly EXIT_RUNTIME_ERROR=3
```

- [ ] complete TODOs