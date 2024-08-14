# STM32MPU Buildroot external tree

This repository is a Buildroot `BR2_EXTERNAL` tree dedicated to
supporting the [STMicroelectronics](https://www.st.com)
[STM32MP1](https://www.st.com/en/microcontrollers-microprocessors/stm32mp1-series.html)
and [STM32MP2](https://www.st.com/en/microcontrollers-microprocessors/stm32mp2-series.html)
platforms. Using this project is not strictly necessary as Buildroot
itself has support for STM32MPU, but this `BR2_EXTERNAL` tree provide
example configurations demonstrating how to use the different features
of the STM32MPU platforms.

## Building Buildroot from source

### Pre-requisites

In order to use [Buildroot](https://www.buildroot.org), you need to
have a Linux distribution installed on your workstation. Any
reasonably recent Linux distribution (Ubuntu, Debian, Fedora, Redhat,
OpenSuse, etc.) will work fine.

Then, you need to install a small set of packages, as described in the
[Buildroot manual System requirements
section](https://buildroot.org/downloads/manual/manual.html#requirement).

For Debian/Ubuntu distributions, the following command allows to
install the necessary packages:

```bash
$ sudo apt install debianutils sed make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio unzip rsync file bc git
```

There are also optional dependencies if you want to use Buildroot features
like interface configuration, legal information or documentation.
Please see the [corresponding manual section](https://buildroot.org/downloads/manual/manual.html#requirement-optional).

### Getting the code

This `BR2_EXTERNAL` tree is designed to work with the `2024.02.x` LTS
version of Buildroot. However, we needed a few changes on top of
upstream Buildroot, so you need to use our own Buildroot fork together
with this `BR2_EXTERNAL` tree, and more precisely its `st/2024.02.3`
branch.

```bash
$ git clone -b st/2024.02.3 https://github.com/bootlin/buildroot.git
```

See our documentation on [internal details](docs/internals.md) for more
information about the changes we have compared to upstream Buildroot.

Now, clone the matching branch of the `BR2_EXTERNAL` tree:

```bash
$ git clone -b st/2024.02.3 https://github.com/bootlin/buildroot-external-st.git
```

You now have side-by-side a `buildroot` directory and a
`buildroot-external-st` directory.

### Configure and build

Go to the Buildroot directory:

```bash
$ cd buildroot/
```

And then, configure the system you want to build by using one of the 8
_defconfigs_ provided in this `BR2_EXTERNAL` tree. For example:

```bash
buildroot/ $ make BR2_EXTERNAL=../buildroot-external-st st_stm32mp157f_dk2_defconfig
```

We are passing two informations to `make`:

1. The path to `BR2_EXTERNAL` tree, which we have cloned side-by-side
   to the Buildroot repository

2. The name of the Buildroot configuration we want to build.

If you want to further customize the Buildroot configuration, you can
now run `make menuconfig`, but for your first build, we recommend you
to keep the configuration unchanged so that you can verify that
everything is working for you.

Start the build:

```bash
buildroot/ $ make
```

This will automaticaly download and build the entire Linux system for
your STM32MPU platform: cross-compilation toolchain, firmware,
bootloader, Linux kernel, root filesystem. It might take between 30
and 60 minutes depending on the configuration you have chosen and how
powerful your machine is.

## Flashing and booting the system

The Buildroot configurations generate a compressed ready-to-use SD card
image, available as `output/images/sdcard.img.gz`. You can also use the
prebuilt images downloaded from the [starter package section](#Starter-package).

Flash this image on a SD card:

```bash
buildroot/ $ gzip -dc sdcard.img.gz | dd of=/dev/sdX bs=1M
```

You can also use the block map image file to accelerate the flashing
process. The block map image is available as
`output/images/sdcard.img.bmap` or can be downloaded from the
[starter package section](#Starter-package). Both the block map file and
the SD card image has to be in the same directory.

Note: bmaptool will not erase empty partition like the U-boot environment
partition.

```bash
buildroot/ $ bmaptool copy sdcard.img.gz /dev/sdbX
```

(Note: this assumes your SD card appears as `/dev/sdX` on your system.)

Then:

1. Insert the microSD card

   - STM32MP157: connector CN15
   - STM32MP135: connector CN3
   - STM32MP257: connector CN1

2. Plug a micro-USB cable or USB-C for STM32MP257 and run your serial
   communication program on /dev/ttyACM0.

   - STM32MP157: connector CN11
   - STM32MP135: connector CN10
   - STM32MP257: connector CN21

3. Configure the SW1 switch to boot on SD card

   - STM32MP157: BOOT0 and BOOT2 to ON
   - STM32MP135: BOOT0 to ON, BOOT1 to OPEN, BOOT2 to ON
   - STM32MP257: BOOT0 to ON, BOOT1 and BOOT2 and BOOT3 to OPEN

4. Plug a USB-C cable or Barrel cable for STM32MP257 to power-up the board

   - STM32MP157: connector CN6
   - STM32MP135: connector CN12
   - STM32MP257: connector CN20

5. The system will start, with the console on UART. You can log-in as
   `root` with no password for the minimal configuration, or with `root`
   as the password for the demo configurations.

Note: it is also possible to flash the SD card while leaving it into
the board, by using the STM32 Cube Programmer. See our [Using the
STM32 Cube Programmer](docs/stm32cubeprogrammer.md) page for more
details.

# References

- [Buildroot](https://buildroot.org/)
- [Buildroot reference manual](https://buildroot.org/downloads/manual/manual.html)
- [Buildroot system development training
  course](https://bootlin.com/training/buildroot/), with freely
  available training materials
