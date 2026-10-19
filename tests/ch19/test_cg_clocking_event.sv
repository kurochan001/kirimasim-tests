/*
:name: test_cg_clocking_event
:description: A covergroup with a clocking event samples its coverpoints at each occurrence of the event (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_clocking_event.expected
*/
// IEEE 1800-2023 §19.3: a covergroup declared with an event, such as
// @(posedge clk), samples its coverpoints whenever the event occurs, without a
// call of sample(). Values that are present only between events are not
// sampled.

`timescale 1ns/1ns

module test_cg_clocking_event;
  bit clk = 0;
  bit [1:0] p = 0;

  covergroup cg @(posedge clk);
    cp: coverpoint p { bins b[] = {[0:3]}; }
  endgroup

  cg inst = new;

  initial begin
    #1 p = 1;
    #1 p = 3;                 // changed again before any clock edge
    #1 p = 2;
    #1 clk = 1;               // samples 2
    #1 clk = 0;
    #1 $display("after one edge: %0.2f", inst.get_inst_coverage());
    p = 1;
    #1 clk = 1;               // samples 1
    #1 $display("after two edges: %0.2f", inst.get_inst_coverage());
  end
endmodule
