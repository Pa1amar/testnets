# 🐛 Bug

Error after `aptos-node` start

Last testnet commit | git checkout 2d8b1b57553d869190f61df1aaf7f31a8fc19a7b

**Stack trace/error message**
```
aptos-node --help
thread 'main' panicked at 'assertion failed: aptos_natives(NativeGasParameters::zeros(),\n            AbstractValueSizeGasParameters::zeros(),\n            LATEST_GAS_FEATURE_VERSION).into_iter().all(|(_, module_name,\n            func_name, _)|\n        module_name.as_str() != \"unit_test\" &&\n            func_name.as_str() != \"create_signers_for_testing\")', aptos-move/aptos-vm/src/natives.rs:55:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

## System information

**Please complete the following information:**
- aptos-node | git checkout 2d8b1b57553d869190f61df1aaf7f31a8fc19a7b
- rustc 1.63.0 (4b91a6ea7 2022-08-08)
- Ubuntu 20.04.5 LTS
