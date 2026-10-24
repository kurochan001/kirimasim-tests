/*
:name: test_illegal_specparam_in_interface
:description: A specparam can be declared only in a module body or a specify block, not in an interface (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.5 25.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the specparam tDel is declared in the body of an interface
:expected_stderr_regex: test_illegal_specparam_in_interface\.sv:20:
*/
// IEEE 1800-2023 §6.20.5, Table 6-11: specify parameters are declared
// inside a module or a specify block. An interface (§25.3) is neither, so
// the specparam in its body is an error; the module that instantiates it is
// legal.

interface test_illegal_specparam_in_interface_if;
  specparam tDel = 3;    // illegal: specparam in an interface
endinterface

module test_illegal_specparam_in_interface;
  test_illegal_specparam_in_interface_if i ();
endmodule
