/*
:name: test_include_guard_twice
:description: A file included twice whose contents are wrapped in `ifndef and `define is compiled once, so its declaration is not repeated (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4 22.6 22.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: include_guard_twice.svh
:expected_stdout: @test_include_guard_twice.expected
*/
// IEEE 1800-2023 §22.4, §22.6: the included file declares a parameter between
// `ifndef and `define of a guard macro (22.5.1). The first `include defines
// the macro and the parameter; at the second, the macro is defined, so
// `ifndef skips the text and the parameter is not declared twice, which
// would be an error.

module test_include_guard_twice;
  `include "include_guard_twice.svh"
  `include "include_guard_twice.svh"

  initial begin
`ifdef INCLUDE_GUARD_TWICE_SVH
    $display("guard defined");
`endif
    $display("depth=%0d", INCLUDE_GUARD_TWICE_DEPTH);
  end
endmodule
