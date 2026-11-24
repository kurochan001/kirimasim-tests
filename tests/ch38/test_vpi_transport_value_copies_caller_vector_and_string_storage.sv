/*
:name: test_vpi_transport_value_copies_caller_vector_and_string_storage
:description: Delayed VPI writes retain the vector and string supplied at each scheduling call
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.15
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vpi_transport_value_copies_caller_vector_and_string_storage.expected
:vpi_c: @test_vpi_transport_value_copies_caller_vector_and_string_storage.c
*/
`timescale 1ns/1ns
module test_vpi_transport_value_copies_caller_vector_and_string_storage;
  logic [39:0] vector_value = 40'h00_1234_5678;
  string text_value = "initial";

  initial begin
    #5 $vt_schedule_values;
    #1 $display("at6 %010h %s", vector_value, text_value);
    #2 $display("at8 %010h %s", vector_value, text_value);
    #2 $display("at10 %010h %s", vector_value, text_value);
  end
endmodule
