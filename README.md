# open-chip-flow
Open-chip-flow is a custom chip design flow based on Python, utilizing common open-source tools into single Python-based hierarchy. 
> [!NOTE]
> Currently, only UVM-based verification is part of this flow, while other design tools (for STA, SYN, PNR, ...) are planned to be included later.

To run a flow, following syntax is used:
```
    python run.py <task> [<arguments>]
```
Each `<task>` is represented as separate step of a flow and is developed independently under `scripts/` directory. To see all currently available tasks, run:
```
    python run.py -h
```
and to see task specific options, run:
```
    python run.py <task> -h
```

## YAML files
Tasks often require YAML file as a first argument, from which it extracts all necessary paths (cell paths, packages...), names, configs and so on. Hence YAML file contains all unique information about top-level design, IP or VIP.

File structure **is strict** and should not be violated as tasks typically expects it. See file `template.yaml` for such structure with description of each node.

YAML file can also include other YAML files, which is typically used to create dependency chains for a design or verification (i.e. include YAML file of Verification IP which is used for verification). Example belows shows typical use case:
```yaml
design:
    verif:
        files:
            - "some-file.sv"
            - "some-other-file.sv"
            - !include                          <-- files from "vip.yaml" under path "design/verif/files" are included here.
                - file: "vip.yaml"
                - path: "design/verif/files"
...
```

## Verification
For running verification on an RTL level, Verilator tool is used. This repository automatically clones UVM repository from `TODO`,
thus UVM can be utilized as well. 
When running a verification, YAML file must be provided. From this file, task searches for `design/verif/files` and `design/rtl/files` where it extracts `.sv[h]` files, compiles them and runs verification. 
```
    python run.py verif <file.yaml> --test i2c_test_rw

```