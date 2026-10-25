/*
:name: test_ifdef_directive_names_not_defined
:description: The names of compiler directives, such as define, include, timescale and resetall, count as not defined for `ifdef, `elsif and `ifndef, also inside a condition expression (IEEE 1800-2023 Section 22.6)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ifdef_directive_names_not_defined.expected
*/
// IEEE 1800-2023 §22.6: although compiler directive names share the name space
// of text macro names, `ifdef and `elsif consider them not defined. So `ifdef
// define, `elsif include and `ifdef (timescale || resetall) fail, `ifndef
// undef succeeds, and (resetall || A) holds only because A is defined. Each
// int records which branch was used. The 5.052 release of Verilator rejects
// `elsif include, and Icarus Verilog 13.0 does not accept the expressions and
// takes `ifdef timescale as defined.

`define A

module test_ifdef_directive_names_not_defined;
`ifdef define
  int r_define = 1;
`elsif include
  int r_define = 2;
`else
  int r_define = 3;
`endif
`ifndef undef
  int r_undef = 1;
`else
  int r_undef = 0;
`endif
`ifdef (timescale || resetall)
  int r_expr = 1;
`else
  int r_expr = 0;
`endif
`ifdef (resetall || A)
  int r_expr_a = 1;
`else
  int r_expr_a = 0;
`endif

  initial
    $display("define/include=%0d undef=%0d expr=%0d expr_a=%0d", r_define, r_undef, r_expr,
             r_expr_a);
endmodule
