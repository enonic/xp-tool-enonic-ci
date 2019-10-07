<img align="right" src="https://raw.githubusercontent.com/enonic/xp/master/misc/logo.png">
<h1>Enonic CI/CD</h1>

This repository is for building images that can be used in CI/CD pipelines to **build**, **test** and **deploy** your XP apps to a running XP instance.

- [Images available](#images-available)
- [CI/CD providers](#cicd-providers)
  - [Required environmental variables](#required-environmental-variables)
  - [CircleCI](#circleci)
  - [Github Actions](#github-actions)
  - [Drone](#drone)
  - [Travis CI](#travis-ci)
  - [Jenkins](#jenkins)
- [Building images](#building-images)

## Images available

These images contain the Enonic CLI, JDK and other build essentials to build your projects:

- `enonic/enonic-ci:7.0.3`
- `enonic/enonic-ci:7.1.1`

## CI/CD providers

### Required environmental variables

In order to deploy your app in a pipeline you have to set 3 environmental variables for your build:

- `ENONIC_CLI_REMOTE_URL=<YOUR_XP_SERVER>`: The default management port is 4848, i.e. `https://myserver.com:4848`
- `ENONIC_CLI_REMOTE_USER=<YOUR_USER>`
- `ENONIC_CLI_REMOTE_PASS=<YOUR_PASS>`

### CircleCI

Remember to create required [environmental variables for project in CircleCI](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project).

Create a file `.circleci/config.yml` in your repo:

```yaml
version: 2.0
jobs:
  build:
    working_directory: ~/app
    docker:
      - image: enonic/enonic-ci:7.1.1
    steps:
      - checkout
      - run:
          name: Setup sandbox
          command: /setup_sandbox.sh # Needed because CircleCI does not respect docker entrypoints
      - run:
          name: Build App
          command: enonic project build
      - run:
          name: Deploy App
          command: enonic app install --file build/libs/*.jar
```

### Github Actions

Remember to create required [environmental variables for project on Github](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables).

Create a file `.github/workflows/enonic.yml` in your repo:

```yaml
name: Enonic CI

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Build and Deploy app
        uses: docker://enonic/enonic-ci:7.1.1
        env:
          ENONIC_CLI_REMOTE_URL: ${{ secrets.ENONIC_CLI_REMOTE_URL }}
          ENONIC_CLI_REMOTE_USER: ${{ secrets.ENONIC_CLI_REMOTE_USER }}
          ENONIC_CLI_REMOTE_PASS: ${{ secrets.ENONIC_CLI_REMOTE_PASS }}
        with:
          args: bash -c "enonic project build && enonic app install --file build/libs/*.jar"
```

### Drone

Remember to create required [environmental variables for project in Drone](https://docs.drone.io/configure/secrets/).

Create a file `.drone.yml` in your repo:

```yaml
kind: pipeline
type: docker
name: default

steps:
  - name: Build App
    image: enonic/enonic-ci:7.1.1
    commands:
      - enonic project build
  - name: Deploy App
    image: enonic/enonic-ci:7.1.1
    environment:
      ENONIC_CLI_REMOTE_URL:
        from_secret: ENONIC_CLI_REMOTE_URL
      ENONIC_CLI_REMOTE_USER:
        from_secret: ENONIC_CLI_REMOTE_USER
      ENONIC_CLI_REMOTE_PASS:
        from_secret: ENONIC_CLI_REMOTE_PASS
    commands:
      - enonic app install --file build/libs/*.jar
```

### Travis CI

Remember to create required [environmental variables for project in TravisCI](https://docs.travis-ci.com/user/environment-variables/#defining-variables-in-repository-settings).

Travis does not allow you to run custom images, so we will use their prebuilt images instead and deploy your app with curl.

Create a file `.travis.yml` in your repo:

```yaml
language: java

jdk:
  - openjdk11

after_success:
  # We pipe the curl command to xargs echo to be able
  # to view the output in the Travis dashboard
  - |
    curl -X POST -f -s -S -o - \
      -u $ENONIC_CLI_REMOTE_USER:$ENONIC_CLI_REMOTE_PASS \
      -F "file=@$(find build/libs/ -name '*.jar')" \
      $ENONIC_CLI_REMOTE_URL/app/install | xargs echo
```

### Jenkins

> **_NOTE:_** This has not been tested!

Remember to create required [credentials for project in Jenkins](https://jenkins.io/doc/book/pipeline/jenkinsfile/#handling-credentials).

Create a file `Jenkinsfile` in your repo:

```
pipeline {
  agent {
    docker {
      image 'enonic/enonic-ci:7.1.1'
    }
  }
  environment {
    ENONIC_CLI_REMOTE_URL  = credentials('jenkins-enonic-url')
    ENONIC_CLI_REMOTE_USER = credentials('jenkins-enonic-user')
    ENONIC_CLI_REMOTE_PASS = credentials('jenkins-enonic-pass')
  }
  stages {
    stage('Build App') {
      steps {
        sh 'enonic project build'
      }
    }
    stage('Deploy App') {
      steps {
        sh 'enonic app install --file build/libs/*.jar'
      }
    }
  }
}
```

## Building images

Log into DockerHub with `docker login` and then run `./create_and_push_images.sh`.
