/*
:name: test_vpi_vector_callback_storage_survives_get_value_until_return
:description: A VPI vector callback keeps its value while the callback fetches a different vector
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vpi_vector_callback_storage_survives_get_value_until_return.expected
:vpi_c: @test_vpi_vector_callback_storage_survives_get_value_until_return.c
*/
`timescale 1ns/1ns
module test_vpi_vector_callback_storage_survives_get_value_until_return;
  logic [39:0] watched = 0;
  logic [39:0] secondary = 40'h12_f234_5678;

  initial begin
    #1 $vt_watch_vector;
    #4 watched = 40'h34_a1x3_56z8;
    #3 watched = 40'h56_zbcx_1234;
    #1 $display("done");
  end
endmodule
