/*
:name: test_n_output_gate_delays
:description: buf and not gates with no delay change at once, with one delay use it for every change, and with two delays rise after the first, fall after the second and go to x after the smaller one (IEEE 1800-2023 Section 28.5)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.5 28.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_n_output_gate_delays.expected
*/
// IEEE 1800-2023 §28.5: buf and not have zero, one or two delays. Without a
// delay there is no propagation delay; one delay is both the rise and the
// fall delay; with two, the first is the rise delay and the second the fall
// delay of the output, and the smaller of them applies to a change to x.
// Table 28-9 of §28.16 gives the fall delay for a change from x to 0 and
// the rise delay for a change from x to 1.
// Three buf and three not gates share input a: no delay, #4 (for buf with
// two outputs) and two delays, #(6, 2) for buf and #(2, 6) for not, so that
// the smaller delay is the fall delay of one and the rise delay of the
// other. Input a goes from 0 to 1, to x, to 0 and to x again every 10 time
// units; a not output falls when a rises. The outputs are printed at odd
// times, when nothing changes.

`timescale 1ns/1ns

module test_n_output_gate_delays;
  logic a;
  wire b0, b1a, b1b, b2, n0, n1, n2;

  buf             gb0 (b0, a);
  buf #4          gb1 (b1a, b1b, a);
  buf #(6, 2)     gb2 (b2, a);
  not             gn0 (n0, a);
  not #4          gn1 (n1, a);
  not #(2, 6)     gn2 (n2, a);

  initial begin
    a = 0;
    #10 a = 1;
    #10 a = 1'bx;
    #10 a = 0;
    #10 a = 1'bx;
  end

  initial begin
    #11;
    repeat (18) begin
      $display("t=%0t buf: %b %b%b %b  not: %b %b %b", $time, b0, b1a, b1b, b2, n0, n1, n2);
      #2;
    end
  end
endmodule
