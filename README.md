<img align="right" src="https://raw.githubusercontent.com/enonic/xp/master/misc/logo.png">
<h1>Enonic CI/CD</h1>

This repository is for building images that can be used in CI/CD pipelines to **build**, **test** and **deploy** your XP apps to a running XP instance.

- [Documentation](#documentation)
- [Images available](#images-available)
- [Building images](#building-images)

## Documentation

See [here for documentation](./docs/index.adoc).

## Images available

These images contain the Enonic CLI, JDK and other build essentials to build your projects:

- `enonic/enonic-ci:7.0`
- `enonic/enonic-ci:7.1`

Because builds only use the JDK and the CLI it would be redunant to create images for every single release. Every minor version should do.

## Building images

Log into DockerHub with `docker login` and then run `./create_and_push_images.sh`.
