/*
:name: test_illegal_interconnect_data_type
:description: An interconnect net cannot be declared with a data type (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1 6.6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interconnect net is declared with the data type logic
:expected_stderr_regex: test_illegal_interconnect_data_type\.sv:20:
*/
// IEEE 1800-2023 §6.7.1: an interconnect net has no data type, only optional
// packed or unpacked dimensions (6.6.8). Icarus Verilog 13.0 and Verilator
// 5.052 stop at this line too, but only because they do not support
// interconnect nets, which does not count.

module test_illegal_interconnect_data_type;
  interconnect logic [3:0] bus;   // illegal: a data type
endmodule
