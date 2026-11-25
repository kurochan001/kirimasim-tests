# Specify blocks in interfaces and VPI

[日本語](vpi-interface-specify-interpretation.md)

<a id="interface-specify-path-ownership"></a>

## Two readings of the standard

The diagram in IEEE 1800-2023 clause 37.6 shows a relationship from an interface to its module paths. Clause 37.39 permits `specify` in interfaces and describes `vpiInstance` as returning the interface owner and the legacy `vpiModule` relation as returning NULL.

Annex A.1.6 defines interface items by enumerating productions that include `module_common_item`. Annex A.1.4 places `specify_block` under `non_port_module_item`. A parser following those productions rejects `specify` inside an interface.

The two tests take their expected results from clause 37.39. One compares an interface with two paths to an interface without paths. The other compares path ownership across two interface instances and a module instance. Ghost, Icarus Verilog 13.0, and Verilator 5.052 and 5.054 rejected `specify` inside both interfaces. The three ledger requirements are unmapped. [Run record](../coverage/qualification/vpi-delay-ownership-20261125.json)
