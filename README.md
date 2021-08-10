# Oceannik's Runner base container image

## Required build dependencies

The image requires a few dependencies to be successfully built.
Run the following command to fetch all required build dependencies:

```
make fetch-build-dependencies
```

This command should automatically create the `build-dependencies` directory and clone all required repositories.

The directory should contain:

### `build-dependencies/bin`

- the `ocean` binary from [oceannik/oceannik](https://github.com/oceannik/oceannik)

### `build-dependencies/src`

- `deployment-strategies/` from [oceannik/deployment-strategies](https://github.com/oceannik/deployment-strategies)
