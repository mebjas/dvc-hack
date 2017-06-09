# dvc-hack
hacky way to implement dvc in ML pipeline (python)

TODOs
===
 - [ ] Even when script is modified, output should be recomputed
 - [ ] if dvc.ps1 is changed, whole pipeline be computed unless explicitly mentioned
 - [x] update `.dvc.dat` with every operation
 - [ ] way to snapshot the environment (dvc.dat + out.* files)

Script
====
dvc.ps1