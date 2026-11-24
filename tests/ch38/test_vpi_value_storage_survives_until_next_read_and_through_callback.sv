/*
:name: test_vpi_value_storage_survives_until_next_read_and_through_callback
:description: VPI time and strength buffers survive property queries and vector callback memory survives a nested read
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vpi_value_storage_survives_until_next_read_and_through_callback.expected
:vpi_c: @test_vpi_value_storage_survives_until_next_read_and_through_callback.c
*/
`timescale 1ns/1ns
module test_vpi_value_storage_survives_until_next_read_and_through_callback;
  time stamp = 64'h0123_4567_89ab_cdef;
  logic [31:0] word = "READ";
  logic [65:0] watched = '0;
  wire powered;
  assign (strong0, weak1) powered = 1'b1;

  initial begin
    #1 $vt_prepare_buffers;
    $display("written time=%h word=%s", stamp, word);
    #2 watched = 66'h2_1357_2468_7654_3210;
    #1 $display("done");
  end
endmodule
