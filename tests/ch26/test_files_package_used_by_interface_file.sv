/*
:name: test_files_package_used_by_interface_file
:description: A package in one source file is imported by an interface in a second file, and both are used by the test, with the files compiled in that order (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.2 25.3 3.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: files_layered_pkg.sv files_layered_if.sv
:expected_stdout: @test_files_package_used_by_interface_file.expected
*/
// IEEE 1800-2023 §26.3: the compilation of a package shall precede the
// compilation of the scopes that import it, so :files: lists the package first
// and the interface that imports it second, and the test, compiled last,
// imports the package as well. The type and the function of the package (§26.2)
// are the same wherever they are imported.

module test_files_package_used_by_interface_file;
  import files_layered_pkg::*;
  files_layered_if link();
  initial begin
    link.word = word_t'(16'h1234);
    #1 $display("word=%h swapped=%h", link.word, swap(link.word));
  end
endmodule
