#!/bin/bash

RUSTFLAGS="-Zunstable-options -Cpanic=immediate-abort -Zlocation-detail=none -Zfmt-debug=none" cargo +nightly-2025-11-30 build -Z build-std=std,panic_abort -Z build-std-features= --target $(rustc --print host-tuple) --release
