- [ ] decide on:
    - [x] controlling the error-flow(use exit in function and trap EXIT with custom cleanup function, or use returns in functions and trap ERR -> conclusion: I trap EXITs and use exit {code} inside my functions)
    - [ ] `make` in docker (should I remove Make and substitute the fucntionality with bash scripts? -> conclusion: I use the functionality of make files *inside* the container, but abandon make and rather use shell scripts)

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
- [ ] check https://discourse.ubuntu.com/c/design-system/cli-guidelines/62 for improvements

- [x] contemplate if I should TODOs regarding templates in the templates repo (I should due to the fact they are actually separate from one another, but I do not want to commit to two repos as long as I am the only contributer to both)

- [ ] add template support for:
    - [x] java with quarkus
    - [ ] java with quarkus jaeger
    - [ ] java with quarkus OTEL-lgtm
    - [ ] java build
    - [ ] java prod
    - [ ] go build
    - [ ] go prod
    - [ ] go with ncurs
    - [ ] go with air
    - [ ] javascript (node)
    - [ ] javascript with vuejs
    - [ ] typescript (ESA?)
    - [ ] java with spring (ESA?, PFH?)
    - [x] python (JL?) (does this need improvements?)
    - [ ] ansible
    - [ ] c (ESA?)
    - [ ] c++
    - [ ] c++ with ncurses
    - [ ] php (HN?)
    - [x] php with symfony (HN?) (double check again)
    - [ ] php with laravel (HN?)
    - [ ] terraform

- [ ] replace Make (&Makefile) in java templates with bash script

- [ ] consider changing the project name because canonical has a program called craft-cli (could lead to confusion)

- [x] decide on: should all container just be named {something}-env || {someting}-compiler || {something}-runtime
    - I'd prefer {something}-env
        - e.g. against {something}-compiler -> node is not a compiler
        - e.g. against {something}-runtime -> having clang or cpp installed in the dev container does not make it a runtime
- [ ] do not pass the project name into the docker-service... remove "container_name" attribute in compose.. *sigghh*

- [ ] stop commiting to main

- [ ] complete TODOs