# FHI-aims build

This is a Docker container for building FHI-aims, it is used to build the FHI-aims binary in a consistent environment.

### Step 1 - Preparation:
You must be able to clone from the FHI-aims git repository using SSH.

If you do not have access to the FHI-aims repository, [contact the FHI-aims developers](https://fhi-aims.org/get-the-code-menu/get-the-code)

If this command works:

```bash
git clone git@aims-git.rz-berlin.mpg.de:aims/FHIaims.git
```

Then you are ready to build, proceed to the next step.

### Step 2 - GPU version

```bash
make gpu
```

### Step 2 - CPU version

```bash
make cpu
```

### Once the build is complete

The binary will be in the `FHIaims/build` directory.

## Common issues

### SSH key not found

If you get an error about the SSH key not being found, it is likely because the key is not in the default location (`~/.ssh/id_ed25519` or `~/.ssh/id_rsa`).

You can either:

1. Add the key to the default location
2. Modify the Makefile to use the location of your key

### Errors during GPU build

If you get an error about the GPU not being found, it is likely because your system does not support the NVIDIA Container Toolkit.

Make sure you have the NVIDIA Container Toolkit installed and configured correctly.
