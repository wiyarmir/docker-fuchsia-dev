# Fuchsia Development environment

# Base Docker Image

* [cogniteev/oracle-java:java8](https://hub.docker.com/r/cogniteev/oracle-java/)

# Building

1. Install [Docker](https://www.docker.com/).

2. Checkout

3. `docker build -t "wiyarmir/fuchsia" .`

**WARNING:** This script assumes you have already accepted the Android License and will check yes for you.

### Usage

    docker run -it --rm wiyarmir/fuchsia

### You came here for Armadillo?

Easy build of a release APK

    docker run --name armadillo wiyarmir/fuchsia:armadillo
    docker cp armadillo:/home/fuchsia/fuchsia/apps/sysui/armadillo/android/app/build/outputs/apk/app-release.apk .

# LICENSE

MIT
