/*
:name: test_illegal_modport_input_written
:description: A module cannot write a variable that its modport declares as an input (IEEE 1800-2023 Section 25.5)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.5 6.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module writes flag, which its modport declares as an input
:expected_stderr_regex: test_illegal_modport_input_written\.sv:24:
*/
// IEEE 1800-2023 §25.5: a modport declares the directions of the signals as
// seen inside the module, so flag is an input port of reader, and assigning to
// an input port variable is illegal (6.5).

interface link;
  logic flag;
  modport rx(input flag);
endinterface

module reader(link.rx port);
  initial port.flag = 1'b1;   // illegal: flag is an input of rx
endmodule

module test_illegal_modport_input_written;
  link l();
  reader r(l);
endmodule
