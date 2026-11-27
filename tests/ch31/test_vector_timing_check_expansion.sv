/*
:name: test_vector_timing_check_expansion
:description: Vector timing checks expose one default check and share a notifier after expansion
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vector_timing_check_expansion
:vpi_c: @test_vector_timing_check_expansion.c
:expected_stdout: @test_vector_timing_check_expansion.expected
*/
`timescale 1ns/1ns
module vector_timing_cell(input logic [2:0] data, input logic [1:0] clk);
  reg notifier = 0;
  specify
    $width(posedge data, 3, 0, notifier);
    $setup(data, posedge clk, 3, notifier);
  endspecify
endmodule

module test_vector_timing_check_expansion;
  logic [2:0] data = 0;
  logic [1:0] clk = 0;
  int data_bit = 0, clk_bit = 0;
  vector_timing_cell dut(data, clk);

  initial begin
    if ($value$plusargs("data_bit=%d", data_bit)) begin end
    if ($value$plusargs("clk_bit=%d", clk_bit)) begin end
    $arm_vector_timing;
    #10 data = 3'b111;
    #1 clk = 2'b11;
    #1 data = 0;
    #2 $report_vector_timing;
    clk = 0;
    #16 data[data_bit] = 1;
    #1 clk[clk_bit] = 1;
    #1 data = 0;
    #2 $report_vector_timing;
    $finish(0);
  end
endmodule
