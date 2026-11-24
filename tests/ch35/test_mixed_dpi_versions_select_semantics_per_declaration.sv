/*
:name: test_mixed_dpi_versions_select_semantics_per_declaration
:description: One application uses legacy and IEEE DPI packed arguments through separate declarations
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.4 H.14.1 H.14.2 A.2.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mixed_dpi_versions_select_semantics_per_declaration.expected
:dpi_c: @test_mixed_dpi_versions_select_semantics_per_declaration.c
*/
module test_mixed_dpi_versions_select_semantics_per_declaration;
  import "DPI" function void transfer_legacy(
    input bit [44:0] source, output bit [44:0] target
  );
  import "DPI-C" function void transfer_modern(
    input bit [44:0] source, output bit [44:0] target
  );

  bit [44:0] older, current;

  initial begin
    transfer_legacy(45'h1555_1234_5678, older);
    transfer_modern(45'h055a_98ab_cdef, current);
    $display("initial legacy=%012h modern=%012h", older, current);
    transfer_modern(older, current);
    transfer_legacy(current, older);
    $display("chained legacy=%012h modern=%012h", older, current);
  end
endmodule
