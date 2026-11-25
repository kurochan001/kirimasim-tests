/*
:name: test_dpi_foreign_precondition_observations
:description: Observe changes in C code behind the same SystemVerilog DPI declarations
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1 35.5.1.2 35.5.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_foreign_precondition_observations.cpp
:expected_stdout: @test_dpi_foreign_precondition_observations.expected
*/
module test_dpi_foreign_precondition_observations;
  import "DPI-C" function void input_view(input bit [33:0] value);
  import "DPI-C" pure function int pure_value(input int value);
  import "DPI-C" function int read_pure_counter();
  import "DPI-C" function int ordinary(input int value);
  import "DPI-C" context function int positive_context(input int value);
  export "DPI-C" function exported_value;

  function int exported_value(input int a);
    $display("SV export visited input=%0d", a);
    return a + 100;
  endfunction

  initial begin
    bit [33:0] value;
    int a, b, result;

    value = 34'h2_1234_5680;
    input_view(value);
    $display("SV input=%h", value);
    a = pure_value(7);
    b = pure_value(7);
    result = read_pure_counter();
    $display("SV pure=%0d/%0d counter=%0d", a, b, result);

    if ($test$plusargs("positive_context")) begin
      result = positive_context(13);
      $display("SV context=%0d", result);
    end
    result = ordinary(9);
    $display("SV ordinary=%0d", result);
  end
endmodule
