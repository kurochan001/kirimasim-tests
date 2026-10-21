/*
:name: test_package_import_program_header
:description: A package imported in a program header is visible in its port declarations and body (IEEE 1800-2023 Section 26.4)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.4 26.3 24.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_program_header.expected
*/
// IEEE 1800-2023 §26.4: an import in a program header, before its port list,
// makes the package items visible in the port declarations and in the body.
// The parameter and typedef of php_pkg give the type and width of the input
// port i, and the program prints the value it receives. §24.3: the program is
// instantiated in the module. §26.3: the names are used without another
// import. Verilator 5.052 does not parse an import in a program header.

package php_pkg;
  parameter int W = 4;
  typedef logic [W-1:0] word_t;
endpackage

program pr import php_pkg::*; (input word_t i);
  initial $display("i=%0d width=%0d", i, $bits(i));
endprogram

module test_package_import_program_header;
  logic [3:0] a = 4'd5;

  pr p(.i(a));

  initial #1 $finish;
endmodule
