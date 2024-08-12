# Yurie/LaTeXTool

LaTeX tools.

## How to use

### Install

Install from this repository:

1. download the built paclet `build/*.paclet`;

2. install the paclet:

    ``` 
    PacletInstall@File["the/path/of/paclet"];
    ```

Load the package(s):

``` 
Needs["Yurie`LaTeXTool`"];
```

### Upgrade

```
PacletInstall["Yurie/LaTeXTool"];
```

### Uninstall

```
PacletUninstall["Yurie/LaTeXTool"];
```

### Documentation

### Todo

Currently the cwl file generation depends on LaTeX-Workshop, which should be decoupled.