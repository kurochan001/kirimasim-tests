/*
:name: test_dpi_c_without_deprecated_packed_declarations
:description: Modern DPI-C transfers a packed vector with the deprecated declarations present or omitted
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.14 H.14.1 I.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_c_without_deprecated_packed_declarations.c
:expected_stdout: @test_dpi_c_without_deprecated_packed_declarations.expected
*/
module test_dpi_c_without_deprecated_packed_declarations;
  import "DPI-C" function void modern_values(input bit [64:0] data, output bit [64:0] result);

  bit [64:0] data = 65'h1_0123_4567_89ab_cdef;
  bit [64:0] result;

  initial begin
    modern_values(data, result);
    $display("SV returned %h", result);
    $finish(0);
  end
endmodule
