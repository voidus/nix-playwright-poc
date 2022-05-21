# Using playwright with nix-provisioned browsers

The playwright docs pretty clearly state that the releases are tied to their
specific browser versions, so this approach will fetch, patch and wrap them.

This repo also showcases how to wire things up for pytest.

## Running the test

`nix-shell --run 'poetry install && poetry run pytest'` or `./run_tests.sh` which does exactly
that.

For playing around, running `nix-shell` followed by `poetry shell` is probably nicer.

Try passing `--headed` or `--browser=firefox` to `pytest`.

## Future work

This is using a pretty blunt method to get the `rpath`, `interpreter` and wrapper: We install the
binary browsers from nixpkgs and take stuff from there. This has a few problems:

- It's inefficient. There's no real need to install nixpgks chrome to do this
- It's brittle. If nixpkgs changes how their wrappers work, some playwright browser versions might
    stop working.

The main reason why I chose this approach is that I do not understand how nixpkgs generates the
wrappers and I don't want to think too much about the specific dependencies. It could
theoretically be advantageous to patchelf and generate the wrappers ourselves, so if you want to
follow that idea, I'd love to see where that goes.

## Acknowledgements

I could not have done this without [this work by ludios](https://github.com/ludios/nixos-playwright)
