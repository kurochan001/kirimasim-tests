/*
:name: test_package_import_module_header
:description: A package imported in a module header is visible in its parameter and port declarations (IEEE 1800-2023 Section 26.4)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.4 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_module_header.expected
*/
// IEEE 1800-2023 §26.4: an import written in a module header, before the
// parameter and port lists, makes the package items visible in those lists as
// well as in the module body. So a parameter default and a port type can come
// from the package.

package pimh_pkg;
  parameter int W = 6;
  typedef logic [W-1:0] word_t;
endpackage

module pimh_leaf import pimh_pkg::*; #(parameter int N = W) (input word_t in, output word_t out);
  assign out = in + word_t'(N);
endmodule

module test_package_import_module_header;
  logic [5:0] a = 6'd10;
  wire [5:0] b;

  pimh_leaf u(.in(a), .out(b));

  initial #1 $display("out=%0d width=%0d", b, $bits(u.out));
endmodule
