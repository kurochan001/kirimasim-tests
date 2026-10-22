/*
:name: test_top_module_from_metadata
:description: When the tool is told the top-level module, only that module and what it instantiates are elaborated, not another module that nothing instantiates (IEEE 1800-2023 Section 23.3.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_top_module_from_metadata
:expected_stdout: @test_top_module_from_metadata.expected
*/
// IEEE 1800-2023 §23.3.1: a module that no module instantiates is a
// top-level module, instantiated once under its own name. §33.5.3: a tool can
// be told which top-level modules to bind. Two modules here are instantiated
// by nothing; the runner names this one as the top (:top_module:), so the
// design is this module and its instance u, and the other module, which would
// print a line as a top-level module, is not part of it.

module test_top_module_from_metadata_other;
  initial $display("the other module runs");
endmodule

module test_top_module_from_metadata_leaf;
  parameter int P = 7;
endmodule

module test_top_module_from_metadata;
  test_top_module_from_metadata_leaf u();
  initial $display("%m runs, u.P=%0d", u.P);
endmodule
