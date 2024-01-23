# pythoneda-runtime-infrastructure/eventstoredb-application

Definition of <https://github.com/pythoneda-runtime-infrastructure/eventstoredb-application>.

## How to declare it in your flake

Check the latest tag of this repository and use it instead of the `[version]` placeholder below.

```nix
{
  description = "[..]";
  inputs = rec {
    [..]
    pythoneda-runtime-infrastructure-eventstoredb-application = {
      [optional follows]
      url =
        "github:pythoneda-runtime-infrastructure-def/eventstoredb-application/[version]";
    };
  };
  outputs = [..]
};
```

Should you use another PythonEDA modules, you might want to pin those also used by this project. The same applies to [nixpkgs](https://github.com/nixos/nixpkgs "nixpkgs") and [flake-utils](https://github.com/numtide/flake-utils "flake-utils").

Use the specific package depending on your system (one of `flake-utils.lib.defaultSystems`) and Python version:

- `#packages.[system].pythoneda-runtime-infrastructure-eventstoredb-application-python38` 
- `#packages.[system].pythoneda-runtime-infrastructure-eventstoredb-application-python39` 
- `#packages.[system].pythoneda-runtime-infrastructure-eventstoredb-application-python310` 
- `#packages.[system].pythoneda-runtime-infrastructure-eventstoredb-application-python311` 

## How to run pythoneda-runtime/boot

``` sh
nix run 'https://github.com/pythoneda-runtime-infrastructure-def/eventstoredb-application/[version]'
```

### Usage

``` sh
nix run https://github.com/pythoneda-runtime-infrastructure-def/eventstoredb-application/[version] [-h|--help] [-p|--http-port httpPort] [-t|--tcp-port tcpPort] [-r|--run-projections "all"] [-i|--insecure] [-a|--enable-atom-over-http]
```
- `-h|--help`: Prints the usage.
- `-p|--http-port`: The HTTP port.
- `-t|--tcp-port`: The TCP/IP port.
- `-r|--run-projections`: Which projections to run.
- `-i|--insecure`: Whether to run EventStoreDB insecurely.
- `-a|--enable-atom-over-http`: Whether to enable Atom over HTTP.
