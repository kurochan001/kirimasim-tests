/*
:name: test_vpi_property_variables_expose_declarations_without_values
:description: A live property exposes its local variable declaration without exposing either attempt's data through VPI
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.52 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_property_variables_expose_declarations_without_values.expected
:vpi_c: @test_vpi_property_variables_expose_declarations_without_values.c
*/
`timescale 1ns/1ns

module test_vpi_property_variables_expose_declarations_without_values;
  logic clk = 0;
  int data = 173, actual = 0;
  int passes = 0, failures = 0;

  property sample_and_match;
    int saved;
    @(posedge clk) (1'b1, saved = data) |=> actual == saved;
  endproperty

  observed: assert property (sample_and_match) passes++;
            else failures++;

  initial begin
    #5 clk = 1;
    #2 $vt_property_decl_value;
    #3;
    clk = 0;
    data = 219;
    actual = 173;
    #5 clk = 1;
    #2 $vt_property_decl_value;
    #3;
    clk = 0;
    actual = 219;
    #5 clk = 1;
    #2 $display("attempts passed=%0d failed=%0d", passes, failures);
    $finish;
  end
endmodule
