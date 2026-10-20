/*
:name: test_files_package_in_other_file
:description: A package declared in a source file compiled before the test can be imported, and its types, parameters and functions used (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.2 3.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: files_package_in_other_file_pkg.sv
:expected_stdout: @test_files_package_in_other_file.expected
*/
// IEEE 1800-2023 §26.2, §26.3: package names are global, and the items of a
// package compiled earlier can be imported in any later file. The package in
// the file that :files: names declares an enumeration, a parameter and a
// function; the test steps a state through the enumeration LIMIT + 1 times.

module test_files_package_in_other_file;
  import files_package_in_other_file_pkg::*;

  state_t s = IDLE;

  initial
    for (int i = 0; i <= LIMIT; i++) begin
      $display("%0d: %s", i, s.name());
      s = next(s);
    end
endmodule
