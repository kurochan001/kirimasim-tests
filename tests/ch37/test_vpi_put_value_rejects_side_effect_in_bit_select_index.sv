/*
:name: test_vpi_put_value_rejects_side_effect_in_bit_select_index
:description: An ordinary dynamic bit select can be written by VPI and a side-effecting index is rejected
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.5 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_put_value_rejects_side_effect_in_bit_select_index.expected
:vpi_c: @test_vpi_put_value_rejects_side_effect_in_bit_select_index.c
*/
`timescale 1ns/1ns
module test_vpi_put_value_rejects_side_effect_in_bit_select_index;
  bit [7:0] payload;
  int index_value;

  initial begin
    $vt_put_bit(payload[1]);
    $display("constant select=%02h", payload);
    index_value = 2;
    $vt_put_bit(payload[index_value]);
    $display("ordinary select=%02h", payload);
    #1 index_value = 4;
    $vt_put_bit(payload[index_value++]);
    $display("after side effect select=%02h", payload);
  end
endmodule
