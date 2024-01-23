# pythoneda-runtime/boot-application

Definition of <https://github.com/pythoneda-runtime/boot-application>.

## How to declare it in your flake

Check the latest tag of this repository and use it instead of the `[version]` placeholder below.

```nix
{
  description = "[..]";
  inputs = rec {
    [..]
    pythoneda-runtime-boot-application = {
      [optional follows]
      url =
        "github:pythoneda-runtime-def/boot-application/[version]";
    };
  };
  outputs = [..]
};
```

Should you use another PythonEDA modules, you might want to pin those also used by this project. The same applies to [nixpkgs](https://github.com/nixos/nixpkgs "nixpkgs") and [flake-utils](https://github.com/numtide/flake-utils "flake-utils").

Use the specific package depending on your system (one of `flake-utils.lib.defaultSystems`) and Python version:

- `#packages.[system].pythoneda-runtime-boot-application-python38` 
- `#packages.[system].pythoneda-runtime-boot-application-python39` 
- `#packages.[system].pythoneda-runtime-boot-application-python310` 
- `#packages.[system].pythoneda-runtime-boot-application-python311` 

## How to run pythoneda-runtime/boot

``` sh
nix run 'https://github.com/pythoneda-runtime-def/boot-application/[version]'
```

### Usage

``` sh
nix run https://github.com/pythoneda-runtime-def/boot-application/[version] [-h|--help] [-d|--de-url defUrl]
```
- `-h|--help`: Prints the usage.
- `-d|--def-url`: The url of the definition repository of the domain to boot.
