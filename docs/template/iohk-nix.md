# IOHK's nix tooling

## [`iohk-nix`](https://github.com/input-output-hk/iohk-nix)

`iohk-nix` is IOHK's shared nix library. It provides some templates to
make working with `haskell.nix` trivial but is non-essential to use
`haskell.nix` infrastructure.

### `lib.nix`

```nix
{{#include lib.nix}}
```

### `iohk-nix.json`
```json
{{#include iohk-nix.json}}
```

### `nix/pkgs.nix`

```nix
{{#include nix/pkgs.nix}}
```

### `default.nix`

```nix
{{#include default.nix}}
```
