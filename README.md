# Portmaster-Rlvm


This is the configuration files and the required steps to build the rlvm engine for handheld emulator devices (Anbernic RG353V, etc.) using the Portmaster scripts for launching.


# Installation

TBD

# Controls

TBD


## Required libs

- [Gl4es](https://github.com/ptitSeb/gl4es)
    built with: cmake .. -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON
- [libsdl1.2-compat](https://github.com/libsdl-org/sdl12-compat)
    built with no fancy options.
- libboost_filesystem.so.1.74.0
- libboost_iostreams.so.1.74.0
- libboost_program_options.so.1.74.0
- libboost_serialization.so.1.74.0
- liblzma.so.5

## Building

    git clone https://github.com/kloptops/rlvm.git

    cd rlvm

    scons --puresdl --release


At the get the `build/rlvm` file at the end.


# TODO:

- [ ] Auto detect which games are found in the games directory, bring up a list if there is more than 1 game detected.
- [ ] Write installation instructions.
- [ ] Write better info
- [ ] Figure out controls.
- [ ] Figure out why menus are crashing.
