/*
:name: test_undefineall
:description: `undefineall removes every text macro defined so far, after which the names can be defined again (IEEE 1800-2023 Section 22.5.3)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.3 22.5.1 22.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_undefineall.expected
*/
// IEEE 1800-2023 §22.5.3: `undefineall undefines every text macro defined with
// `define so far in the compilation unit, and it may appear anywhere. After it,
// `ifdef (22.6) finds the names undefined, and `define (22.5.1) can define
// them again. Icarus Verilog 13.0 does not know `undefineall and treats it as
// an empty macro, so the macros stay defined.

`define UA_ONE 1
`define UA_TWO 2

module test_undefineall;
  int sum_first = `UA_ONE + `UA_TWO;
`undefineall
`ifdef UA_ONE
  int one_defined = 1;
`else
  int one_defined = 0;
`endif
`ifdef UA_TWO
  int two_defined = 1;
`else
  int two_defined = 0;
`endif
`define UA_ONE 10
  int redefined = `UA_ONE;

  initial $display("sum_first=%0d one_defined=%0d two_defined=%0d redefined=%0d",
                   sum_first, one_defined, two_defined, redefined);
endmodule
