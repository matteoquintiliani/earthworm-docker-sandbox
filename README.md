# Earthworm Docker Sandbox

A Docker tool for learning, testing and running Earthworm System within enclosed environments.

### Earthworm

Software [http://earthworm.isti.com/trac/earthworm/](http://earthworm.isti.com/trac/earthworm/)

### Dependencies

  - Docker
  - GNU Make
  - bash
  - sed
  - grep
  - find

### Help and Earthworm Environments

```sh
make help
```

Short help:

```
 Syntax: make  [ EW_ENV=<ew_env_subdir_name> ]  <command>

 Current main variable values:
     EW_ENV=ew_default
     EW_ENV_MAINDIR=~/ew_envs
     EW_ENV_DIR=~/ew_envs/ew_default

 Earthworm Environment:
     - name is defined by EW_ENV
     - directory is in EW_ENV_MAINDIR with name EW_ENV
     - directory path is EW_ENV_DIR

 An Earthworm Environment Directory must contain the following directories:
     - params: contains Earthworm configuration files (EW_PARAMS variable)
     - log: where log file are written (EW_LOG variable)
     - data: where additional files are read and written (EW_DATA_DIR variable)
```

### Configuration

All configuration variables can be set within file `Makefile.env` except for `EW_ENV` which defines the current Earthworm Environment and it is defined at run-time as argument to `make` command. Example:

```sh
Syntax: make  EW_ENV=ew_default  <command>
```

### Build Docker Image

Default:

```sh
make build
```

#### Compile Earthworm modules

Default settings compile all Earthworm modules from last revision in the main Subversion directory from `svn://svn.isti.com/earthworm/trunk`.

You can choose to compile only specific modules by setting variable `ARG_SELECTED_MODULE_LIST` in `Makefile.env`. Example:
```sh
ARG_SELECTED_MODULE_LIST=" \
reporting/statmgr \
reporting/diskmgr \
reporting/copystatus \
...
...
...
seismic_processing/pick_ew \
seismic_processing/pick_FP \
seismic_processing/binder_ew\
"
```

N.B. In any case `libsrc` and all modules in `system_control` and `diagnostic_tools` will be compiled.

Moreover, you can choose to compile a particolar Subversion directory or revision. Example:

```sh
# You can set custom main directories (e.g. 'tags/ew_7.10_release', 'branches/cosmos', etc.)
EW_SVN_BRANCH = trunk
# EW_SVN_BRANCH = tags/ew_7.10_release

# Set optional Earthworm Revision. If it is empty that stands for last revision of the EW_SVN_BRANCH
# You can set custom subversion revision 'NNN' where NNN is the revision number
EW_SVN_REVISION =
# EW_SVN_REVISION = 8104

```

# Author

Matteo Quintiliani - Istituto Nazionale di Geofisica e Vulcanologia - Italy

Mail bug reports and suggestions to *matteo.quintiliani [at] ingv.it*

