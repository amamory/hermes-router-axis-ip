# Vivado MODULE NAME

This repo contains scripts to recreate **DESCRIBE THE MODULE HERE**. The project is setup for Zedboard, although it would be easy to change to other boards assuming you have some basic TCL skills.

The scripts are quite reusable if you keep the same dir structure. It should be useful for other Vivado/SDK projects with minor efforts.

# Module/IP design

![IP interface block](ip-interface.png)

# How to download it

This repository might have custom IPs included as git submodules. Thus, the following command is required to download all its dependencies.

```
git clone --recursive https://github.com/amamory/<repo-name>.git
```

If you already cloned the repository without `--recursive`, then run the following command to download all the submodules.

```
git submodule update --init --recursive
```

Refer to this [tutorial](https://www.vogella.com/tutorials/GitSubmodules/article.html) to learn how to manage submodules.


# How to run it

These scripts are assuming Linux operation system (Ubuntu 18.04) and Vivado 2018.2.

Follow these instructions to recreate the Vivado and SDK projects:
 - Open the **build.sh** script and edit the first two lines to setup the environment variables 
**VIVADO**, **VIVADO_DESIGN_NAME**, **XIL_APP_NAME**, and **VIVADO_TOP_NAME** (optional). 
 - run *build.sh*

These scripts will recreate the entire Vivado project, compile the design, generate the bitstream, export the hardware to SDK, create the SDK projects, import the source files, build all projects, and finally download both the bitstream and the elf application. Hopefully, all these steps will be executed automatically.

# Future work

 - update the scripts to Vitis
 - support or test with Windows (help required !!! :D )

# Credits

The scripts are based on the excellent scripts from [fpgadesigner](https://github.com/fpgadeveloper/zedboard-axi-dma) plus few increments from my own such as project generalization, support to SDK project creation and compilation and other minor improvements. 
