# Enonic CI/CD images

This repository is for building images that can be used in CI/CD pipelines.

## Images available

* `enonic/enonic-ci:7.0.1`
* `enonic/enonic-ci:7.1.0`

## CircleCI example

For this to work you must create [environmental variables for project in CircleCI](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project):
* `ENONIC_CLI_REMOTE_URL=<YOUR_XP_SERVER>`: Note the default management port is 4848
* `ENONIC_CLI_REMOTE_USER=<YOUR_USER>`
* `ENONIC_CLI_REMOTE_PASS=<YOUR_PASS>`

Create a file `.circleci/config.yml` in your repo:

```yaml
version: 2.0
jobs:
  build:
    working_directory: ~/app
    docker:
      - image: enonic/enonic-ci:7.1.0
    steps:
      - checkout
      - run:
          name: Setup sandbox
          command: |
            /setup_sandbox.sh # Needed because CircleCI does not respect docker entrypoints
      - run:
          name: Build App
          command: |
            enonic project build
      - run:
          name: Deploy App
          command: enonic app install --file build/libs/*.jar
```

## Github Actions example

For this to work you must create [secrets for your Github actions](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables):
* `ENONIC_CLI_REMOTE_URL=<YOUR_XP_SERVER>`: Note the default management port is 4848
* `ENONIC_CLI_REMOTE_USER=<YOUR_USER>`
* `ENONIC_CLI_REMOTE_PASS=<YOUR_PASS>`

Create a file `.github/workflows/enonic.yml` in your repo:

```yaml
name: Enonic CI

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Build App
        uses: docker://enonic/enonic-ci:7.1.0
        with:
          args: enonic project build
      - name: Deploy App
        uses: docker://enonic/enonic-ci:7.1.0
        env:
          ENONIC_CLI_REMOTE_URL: ${{ secrets.ENONIC_CLI_REMOTE_URL }}
          ENONIC_CLI_REMOTE_USER: ${{ secrets.ENONIC_CLI_REMOTE_USER }}
          ENONIC_CLI_REMOTE_PASS: ${{ secrets.ENONIC_CLI_REMOTE_PASS }}
        with:
          args: bash -c "enonic app install --file build/libs/*.jar"
```

## Drone example

Note: This has not been tested.

For this to work you must create [secrets for your Drone project](https://docs.drone.io/configure/secrets/):
* `ENONIC_CLI_REMOTE_URL=<YOUR_XP_SERVER>`: Note the default management port is 4848
* `ENONIC_CLI_REMOTE_USER=<YOUR_USER>`
* `ENONIC_CLI_REMOTE_PASS=<YOUR_PASS>`

Create a file `.drone.yml` in your repo:

```yaml
kind: pipeline
type: docker
name: default

steps:
  - name: Build App
    image: enonic/enonic-ci:7.1.0
    commands:
      - enonic project build
  - name: Deploy App
    image: enonic/enonic-ci:7.1.0
    environment:
      ENONIC_CLI_REMOTE_URL:
        from_secret: ENONIC_CLI_REMOTE_URL
      ENONIC_CLI_REMOTE_USER:
        from_secret: ENONIC_CLI_REMOTE_USER
      ENONIC_CLI_REMOTE_PASS:
        from_secret: ENONIC_CLI_REMOTE_USER
    commands:
      - bash -c "enonic app install --file build/libs/*.jar"
```
