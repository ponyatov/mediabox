# var
MODULE  = $(notdir $(CURDIR))
module  = $(shell echo $(MODULE) | tr A-Z a-z)
OS      = $(shell uname -o|tr / _)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES  ?= $(shell grep processor /proc/cpuinfo | wc -l)

# version
BR_VER    = 2023.05.1
LINUX_VER = 6.3.12

# dir
CWD = $(CURDIR)
GZ  = $(HOME)/gz
CAR = $(HOME)/.cargo/bin

# tool
CURL   = curl -L -o
RUSTUP = $(CAR)/rustup

# src
R += $(wildcard src/*.rs lib/src/*.rs )
R += $(wildcard server/src/*.rs sdl/src/*.rs browser/src/*.rs )
S += $(R) Cargo.toml lib/Cargo.toml
S += server/Cargo.toml sdl/Cargo.toml browser/Cargo.toml

# package
BR = buildroot-$(BR_VER)
BR_GZ = $(BR).tar.gz

# all
.PHONY: all
all: server sdl browser

.PHONY: server sdl browser
server:
	cargo watch -p $@
sdl:
	cargo watch -p $@
browser:
	cargo watch -p $@

# buildroot

APP ?= $(MODULE)
HW  ?= qemu386
include   hw/$(HW).mk
include  cpu/$(CPU).mk
include arch/$(ARCH).mk
include  app/$(APP).mk

BR_CONFIG     = $(BR)/.config
KERNEL_CONFIG = $(BR)/output/build/linux-$(LINUX_VER)/.config

.PHONY: br
br: $(BR_CONFIG) $(KERNEL_CONFIG)
	cd $(BR) ; make menuconfig && make linux-menuconfig && make

.PHONY: $(BR_CONFIG)
$(BR_CONFIG): $(BR)/README
	rm -f $@ ; make -C $(BR) allnoconfig
#
	cat  all/all.br     >> $@
	cat arch/$(ARCH).br >> $@
	cat  cpu/$(CPU).br  >> $@
	cat   hw/$(HW).br   >> $@
	cat  app/$(APP).br  >> $@
#
	echo 'BR2_DL_DIR="$(GZ)"'                                          >> $@
	echo 'BR2_ROOTFS_OVERLAY="$(CWD)/root"'                            >> $@
	echo 'BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE="$(CWD)/all/all.kernel"' >> $@
	echo 'BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES="$(CWD)/arch/$(ARCH).kernel $(CWD)/cpu/$(CPU).kernel $(CWD)/hw/$(HW).kernel $(CWD)/all/all.kernel $(CWD)/hw/$(HW).kernel $(CWD)/app/$(APP).kernel"' >> $@
	echo 'BR2_PACKAGE_BUSYBOX_CONFIG_FRAGMENT_FILES="$(CWD)/all/all.bb $(CWD)/app/$(APP).bb"' >> $@

.PHONY: $(KERNEL_CONFIG)
$(KERNEL_CONFIG): $(BR)/.config
	mkdir -p $(BR) $(BR)/output $(BR)/output/build $(BR)/output/build/linux-$(LINUX_VER)
	cat all/all.kernel > $@

$(BR)/README: $(GZ)/$(BR_GZ)
	zcat $< | tar x && touch $@

$(GZ)/$(BR_GZ):
	$(CURL) $@ https://github.com/buildroot/buildroot/archive/refs/tags/2023.05.1.tar.gz

QEMU_KERNEL = $(BR)/output/images/bzImage
QEMU_INITRD = $(BR)/output/images/rootfs.cpio
qemu: $(QEMU_KERNEL)
	$(QEMU) $(QEMU_CFG) \
		-kernel $(QEMU_KERNEL) -initrd $(QEMU_INITRD)

# install
.PHONY: install update

install: gz $(RUSTUP)
	cargo install cargo-watch
	$(MAKE) update
update:
	sudo apt update
	sudo apt install -yu `cat apt.dev apt.txt`

.PHONY: gz
gz: $(BR)/README

$(RUSTUP):
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# merge
MERGE += Makefile README.md .gitignore .clang-format LICENSE $(S)
MERGE += apt.dev apt.txt apt.msys
MERGE += app hw cpu arch all

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
#	$(MAKE) doxy ; git add -f docs

.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow

ZIP = tmp/$(MODULE)_$(NOW)_$(REL)_$(BRANCH).zip
zip:
	git archive --format zip --output $(ZIP) HEAD
