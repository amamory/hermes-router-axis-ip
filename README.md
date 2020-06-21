# Vivado MODULE NAME

This repo contains scripts to recreate **DESCRIBE THE MODULE HERE**. The project is setup for Zedboard, although it would be easy to change to other boards assuming you have some basic TCL skills.

The scripts are quite reusable if you keep the same dir structure. It should be useful for other Vivado/SDK projects with minor efforts.

# IP interface

![IP interface block](ip-interface.png)

# How to run it

These scripts are assuming Linux operation system (Ubuntu 18.04) and Vivado 2018.2.

Follow these instructions to recreate the Vivado and SDK projects:
 - Open the **build.sh** script and edit the first two lines to setup the environment variables 
**VIVADO** and **VIVADO_DESIGN_NAME**, and **VIVADO_TOP_NAME** (optional). 
 - run *build.sh*

These scripts will recreate the entire Vivado project, compile the design, and elaborate it. The bitstream is not generated since it is an IP core.

# Future work

 - support or test with Windows (help required !!! :D )

# Credits

The scripts are based on the excellent scripts from [fpgadesigner](https://github.com/fpgadeveloper/zedboard-axi-dma) plus few increments from my own such as project generalization, support to SDK project creation and compilation and other minor improvements. 
