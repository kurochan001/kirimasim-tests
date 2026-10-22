/*
:name: test_top_module_excludes_file_module
:description: When the top-level module is named, a module of another source file that nothing instantiates is not elaborated, while the modules the top instantiates are (IEEE 1800-2023 Section 23.3.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.1 3.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: files_top_parts.sv
:top_module: test_top_module_excludes_file_module
:expected_stdout: @test_top_module_excludes_file_module.expected
*/
// IEEE 1800-2023 §23.3.1: without a named top, every module that nothing
// instantiates is a top-level module, which would make the stray module of the
// other file (:files:) one and print its line. §33.5.3: the tool can be told
// the top-level module; the runner names this one (:top_module:), so the design
// is this module and the counter it instantiates from the other file.

module test_top_module_excludes_file_module;
  files_top_counter #(.START(7)) c();
  initial #1 $display("counter value=%0d", c.value);
endmodule
