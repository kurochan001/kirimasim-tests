/*
:name: test_include_file_declarations
:description: `include inserts the whole text of the named file where the directive is, so declarations in the file become part of the module that includes it (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: include_file_declarations.svh
:expected_stdout: @test_include_file_declarations.expected
*/
// IEEE 1800-2023 §22.4: `include replaces the directive with the contents of
// the file. The file that :files: names holds a typedef and a function, so
// they are declared inside the module where it is included. A quoted relative
// name is searched in the current directory and in the locations the user
// gives; the runners give the directory of the test.

module test_include_file_declarations;
  `include "include_file_declarations.svh"

  include_file_declarations_pair_t p = 8'h3a;

  initial $display("hi=%0d lo=%0d sum=%0d", p.hi, p.lo, include_file_declarations_sum(p));
endmodule
