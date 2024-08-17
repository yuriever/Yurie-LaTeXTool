# Yurie/LaTeXTool

LaTeX tools.

## Install

Install from this repository:

1. download the built paclet `build/*.paclet`;

2. install the paclet:

    ``` wl
    PacletInstall@File["the/path/of/paclet"]
    ```

Install manually:

1. download this repository, and move it to the paclet directory `$UserBasePacletsDirectory`;

2. rebuild the internal paclet data:

    ``` wl
    PacletDataRebuild[]
    ```

## Load

``` wl
Needs["Yurie`LaTeXTool`"]
```

## Upgrade

``` wl
PacletInstall["Yurie/LaTeXTool"]
```

## Uninstall

``` wl
PacletUninstall["Yurie/LaTeXTool"]
```

## Documentation

## Todo

Currently the cwl file generation depends on LaTeX-Workshop, which should be decoupled.
