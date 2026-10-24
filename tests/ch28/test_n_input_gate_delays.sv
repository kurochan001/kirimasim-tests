/*
:name: test_n_input_gate_delays
:description: an and gate with no delay changes at once, with one delay uses it for every change, and with two delays rises after the first, falls after the second and goes to x after the smaller one (IEEE 1800-2023 Section 28.4)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4 28.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_n_input_gate_delays.expected
*/
// IEEE 1800-2023 §28.4: a multiple-input gate has zero, one or two delays.
// Without a delay there is no propagation delay; one delay is both the rise
// and the fall delay; with two, the first is the rise delay, the second the
// fall delay, and the smaller of them applies to a change to x. Table 28-9
// of §28.16 gives the fall delay for a change from x to 0.
// Four and gates share the inputs a and b, with b held at 1: no delay, #4,
// #(6, 2) and #(2, 6). Input a goes from 0 to 1, to x, to 0 and to x again,
// every 10 time units, so the outputs rise, change from 1 to x, fall from x
// and change from 0 to x. With both orders of the two delays, a change to x
// after the rise or after the fall delay alone would show in one of them.
// The outputs are printed at odd times, when nothing changes.

`timescale 1ns/1ns

module test_n_input_gate_delays;
  logic a, b;
  wire y0, y1, y2, y3;

  and             g0 (y0, a, b);
  and #4          g1 (y1, a, b);
  and #(6, 2)     g2 (y2, a, b);
  and #(2, 6)     g3 (y3, a, b);

  initial begin
    a = 0; b = 1;
    #10 a = 1;
    #10 a = 1'bx;
    #10 a = 0;
    #10 a = 1'bx;
  end

  initial begin
    #11;
    repeat (18) begin
      $display("t=%0t none=%b #4=%b #(6,2)=%b #(2,6)=%b", $time, y0, y1, y2, y3);
      #2;
    end
  end
endmodule
