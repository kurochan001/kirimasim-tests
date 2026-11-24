/*
:name: test_vpi_legacy_array_property_on_variable_elements
:description: The deprecated VPI array property distinguishes a variable element from a standalone variable
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_legacy_array_property_on_variable_elements.expected
:expected_exit: 0
:vpi_c: @test_vpi_legacy_array_property_on_variable_elements.c
*/
module test_vpi_legacy_array_property_on_variable_elements;
  logic [7:0] standalone_logic = 8'h31;
  logic [7:0] logic_rows [3:4];
  int standalone_int = 11;
  int int_rows [-3:-2];

  initial begin
    logic_rows[4] = 8'h82;
    int_rows[-2] = 37;
    #1 $probe_array_vars;
  end
endmodule
