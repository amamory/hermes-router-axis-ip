# Vivado MODULE NAME

This repo contains scripts to recreate **DESCRIBE THE MODULE HERE**. The project is setup for Zedboard, although it would be easy to change to other boards assuming you have some basic TCL skills.

# Module/IP design

Describe here your module interface and protocols.

![Place here a nice picture of your design](my-awesome-module.png)

# How to use this repository

These scripts presented here are quite reusable if you keep the same dir structure. It should be useful for other Vivado/SDK projects with minor efforts. For this reason this repository is a template. Just click in **Use this Template** button to replicate it for your own project.

In command line, create an empty repository called *<your-reponame>* in github and follow these steps to use it as a template:

```
mkdir <my-new-project>
cd <my-new-project>
git clone https://github.com/amamory/vivado-base-project.git .
rm -rf .git
git init
git remote set-url origin https://github.com/<your-username>/<your-reponame>
git add * .gitignore
git commit -m "my initial commit"
git push origin master
```

Each directory has instructions related to the kind of file you have to place in them.

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
