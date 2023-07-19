# var
MODULE  = $(notdir $(CURDIR))
module  = $(shell echo $(MODULE) | tr A-Z a-z)
OS      = $(shell uname -o|tr / _)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES  ?= $(shell grep processor /proc/cpuinfo | wc -l)

# src
R += $(wildcard src/*.rs lib/src/*.rs )
R += $(wildcard server/src/*.rs sdl/src/*.rs browser/src/*.rs )
S += $(R) Cargo.toml lib/Cargo.toml
S += server/Cargo.toml sdl/Cargo.toml browser/Cargo.toml

# all
.PHONY: all
all: server sdl browser

.PHONY: server sdl browser
server:
	cargo run -p $@
sdl:
	cargo run -p $@
browser:
	cargo run -p $@

# merge
MERGE += Makefile README.md .gitignore .clang-format LICENSE $(S)
MERGE += apt.dev apt.txt apt.msys

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
