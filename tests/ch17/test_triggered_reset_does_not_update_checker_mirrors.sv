/*
:name: test_triggered_reset_does_not_update_checker_mirrors
:description: Triggered resets without notifying either checker assignment
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.9 9.4.4 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_triggered_reset_does_not_update_checker_mirrors
:expected_stdout: @test_triggered_reset_does_not_update_checker_mirrors.expected
*/
`timescale 1ns/1ns
checker triggered_reset_mirrors(sequence endpoint, input logic armed,
                                output logic continuous_value, output logic combinational_value);
  assign continuous_value = endpoint.triggered && armed;
  always_comb combinational_value = endpoint.triggered && armed;
endchecker

module test_triggered_reset_does_not_update_checker_mirrors;
  logic clk = 0, req = 0, ack = 0, armed = 0;
  wire continuous_value;
  logic combinational_value;
  time covered_at = 0, waited_at = 0;
  logic covered_status = 0, waited_status = 0;
  always #5 clk = ~clk;

  sequence complete;
    @(posedge clk) req ##1 ack;
  endsequence
  triggered_reset_mirrors observe(complete, armed, continuous_value, combinational_value);

  cover sequence (complete) begin
    covered_at = $time;
    covered_status = complete.triggered;
    armed = 1;
  end

  initial begin
    wait (complete.triggered);
    waited_at = $time;
    waited_status = complete.triggered;
  end

  initial begin
    #2 req = 1;
    #10 req = 0;
    ack = 1;
    $display("before t=%0d wire=%0b comb=%0b", $time, continuous_value, combinational_value);
    #4 $display("completion cover=%0d/%0b wait=%0d/%0b",
                covered_at, covered_status, waited_at, waited_status);
    $display("reset t=%0d direct=%0b wire=%0b comb=%0b",
             $time, complete.triggered, continuous_value, combinational_value);
    #6 armed = 0;
    #1 $display("input change t=%0d direct=%0b wire=%0b comb=%0b",
                $time, complete.triggered, continuous_value, combinational_value);
    $finish(0);
  end
endmodule
