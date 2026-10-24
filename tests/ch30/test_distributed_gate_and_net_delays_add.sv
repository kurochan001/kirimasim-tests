/*
:name: test_distributed_gate_and_net_delays_add
:description: Distributed delays are the delays of the gates and nets inside a module, so an input change reaches the output after the gate delay plus the net delay on its way, with no module path delay (IEEE 1800-2023 Section 30.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_distributed_gate_and_net_delays_add.expected
*/
// IEEE 1800-2023 §30.2: distributed delays specify the time it takes events to
// propagate through the gates and nets inside a module (28.16), while module
// path delays describe the time from a source port to a destination port.
// dgd_cell has no specify block: its and gate has the delay 3 and drives the
// net n, whose net delay is 2, and the buf to y has no delay, so a change of a
// reaches y after 5. a rises at 10; $strobe shows y at the end of the time
// steps 14 and 15. Icarus Verilog 13.0 does not support the net delay
// ("sorry: Net delays not supported").

`timescale 1ns/1ns

module dgd_cell(input wire a, input wire b, output wire y);
  wire #2 n;
  and #3 g1 (n, a, b);
  buf g2 (y, n);
endmodule

module test_distributed_gate_and_net_delays_add;
  logic a = 1'b0, b = 1'b1;
  wire y;
  dgd_cell u (.a(a), .b(b), .y(y));
  initial begin
    #10 a = 1'b1;
    #4 $strobe("t=%0t y=%b", $time, y);
    #1 $strobe("t=%0t y=%b", $time, y);
  end
endmodule
