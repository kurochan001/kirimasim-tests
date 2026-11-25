/*
:name: test_clocked_checker_window_from_sequence_endpoints
:description: A clocked checker keeps a window between sequence completions
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.9 17.7.3 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_clocked_checker_window_from_sequence_endpoints
:expected_stdout: @test_clocked_checker_window_from_sequence_endpoints.expected
*/
`timescale 1ns/1ns
checker clocked_endpoint_window(sequence opening, sequence closing, input logic clk,
                                output logic high);
  bit active = 0;
  let open_flag = opening.triggered;
  let close_flag = closing.triggered;
  assign high = active;
  always_ff @(posedge clk) begin
    if (close_flag)
      active <= 0;
    else if (open_flag)
      active <= 1;
  end
endchecker

module test_clocked_checker_window_from_sequence_endpoints;
  logic clk = 0, open_req = 0, open_ack = 0, close_req = 0, close_ack = 0;
  wire window;
  always #5 clk = ~clk;

  sequence open_pulse;
    @(posedge clk) open_req ##1 open_ack;
  endsequence
  sequence close_pulse;
    @(posedge clk) close_req ##1 close_ack;
  endsequence

  clocked_endpoint_window dut(open_pulse, close_pulse, clk, window);

  initial begin
    #2 open_req = 1;
    #10 open_req = 0;
    open_ack = 1;
    $display("before open=%0b", window);
    #4 $display("opened=%0b open flag=%0b", window, open_pulse.triggered);
    #6 open_ack = 0;
    #4 $display("held=%0b", window);
    #6 close_req = 1;
    #10 close_req = 0;
    close_ack = 1;
    $display("before close=%0b", window);
    #4 $display("closed=%0b close flag=%0b", window, close_pulse.triggered);
    $finish(0);
  end
endmodule
