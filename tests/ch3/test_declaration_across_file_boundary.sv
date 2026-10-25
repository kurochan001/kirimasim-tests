/*
:name: test_declaration_across_file_boundary
:description: A declaration that is not complete at the end of a file continues in the next file, as the compilation unit then extends over the following files (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: declaration_across_file_boundary_head.sv declaration_across_file_boundary_tail.sv
:expected_stdout: @test_declaration_across_file_boundary.expected
*/
// IEEE 1800-2023 §3.12.1: if a declaration is incomplete at the end of a
// file, the compilation unit that includes the file extends through the
// following files until no declaration is incomplete. This holds whether the
// tool makes one compilation unit of all the files or one of each file.
// The first file that :files: names starts the module
// declaration_split_module and assigns a; the second file assigns b from a
// and ends the module. The test instantiates it and prints both outputs.
// The release 5.052 of Verilator reports a syntax error at the end of the
// first file.

module test_declaration_across_file_boundary;
  int a, b;

  declaration_split_module u(.a(a), .b(b));

  initial #1 $display("a=%0d b=%0d", a, b);
endmodule
