/*
:name: test_negative_setup_shift_clamps_adjusted_hold_and_warns
:description: A clock shift from a negative setup limit clamps a shorter adjusted hold limit to zero
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.9.4 31.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_setup_shift_clamps_adjusted_hold_and_warns.expected
:expected_stderr_regex: (?im)^(?=[^\n]*warning)(?=[^\n]*(?:hold|timing|limit))(?=[^\n]*(?:clamp|set to zero|adjusted[^\n]*non.?positive|adjusted[^\n]*less[^\n]*zero))[^\n]+
*/
// The expected results require negative timing checks to be enabled.
`timescale 1ns/1ns
module shifted_hold(input wire clk, data);
  wire delayed_clk, delayed_data;
  reg neg_notifier = 0, hold_notifier = 0;
  specify
    $setuphold(posedge clk, posedge data, -5, 7, neg_notifier, , , delayed_clk, delayed_data);
    $hold(posedge clk, posedge data, 2, hold_notifier);
  endspecify
endmodule
module raw_hold(input wire clk, data);
  reg hold_notifier = 0;
  specify
    $hold(posedge clk, posedge data, 2, hold_notifier);
  endspecify
endmodule
module test_negative_setup_shift_clamps_adjusted_hold_and_warns;
  bit clk, data;
  shifted_hold mixed(clk, data);
  raw_hold control(clk, data);

  initial begin
    #20 clk = 1;
    #1 data = 1;
    #10 $display("adjusted=%b control=%b composite=%b",
                 mixed.hold_notifier, control.hold_notifier, mixed.neg_notifier);
  end
endmodule
