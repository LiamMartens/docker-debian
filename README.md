# Debian base image
This is a base debian stretch image

## Build arguments
* `USER`: The non-root user to add during the build (`user` by default)
* `SHELL`: The default shell
* `TIMEZONE`: The timezone to use in the container

## Useful information
* The `container-init` script runs all scripts in `$DOCKER_PROVISION_DIR`, by default `/opt/docker/provision`
* Apart from the `container-init` script, there are also `escape` and `fileenv`. The first script escapes quotes and the latter fetches and environment variable taking into account the regularly used `ENV_FILE` Docker pattern.
* Apart from `$DOCKER_PROVISION_DIR` there are also `$DOCKER_DIR`, `$DOCKER_ETC_DIR`, `$DOCKER_BIN_DIR` and `$DOCKER_TMP_DIR`.