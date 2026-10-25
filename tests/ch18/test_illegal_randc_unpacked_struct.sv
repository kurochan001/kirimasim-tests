/*
:name: test_illegal_randc_unpacked_struct
:description: an unpacked structure declared randc is an error (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class member bad is an unpacked structure declared randc
:expected_stderr_regex: test_illegal_randc_unpacked_struct\.sv:29:
*/
// IEEE 1800-2023 §18.4: an unpacked structure can be declared rand, and its
// members can be made random by a rand or randc modifier in the declaration
// of the structure type, but an unpacked structure shall not be declared
// randc. The member good is an unpacked structure declared rand whose type
// has a randc member, which is legal. The member bad is an unpacked
// structure declared randc, which is the error.
// Icarus Verilog 13.0 does not support unpacked structures, so its error
// does not count.

class rus_obj;
  rand struct {
    randc bit [1:0] k;
    rand bit [3:0] d;
  } good;

  randc struct { bit [3:0] a; } bad;   // illegal: unpacked structure declared randc
endclass

module test_illegal_randc_unpacked_struct;
  rus_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
