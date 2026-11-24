/*
:name: test_vpi_nettype_declarations_belong_to_declaring_instance
:description: The instance nettype iterator returns local declarations and excludes a nested type
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_nettype_declarations_belong_to_declaring_instance.expected
:vpi_c: @test_vpi_nettype_declarations_belong_to_declaring_instance.c
*/
module test_vpi_nettype_declarations_belong_to_declaring_instance;
  nettype logic [3:0] nibble;
  nettype logic [7:0] octet;
  nibble a;
  octet b;

  if (1) begin : generated
    nettype logic [1:0] hidden_type;
    hidden_type c;
  end

  initial #1 $finish;
endmodule
