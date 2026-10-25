/*
:name: test_net_decl_assign_delay_is_driver_delay
:description: the delay of a net declaration assignment delays only that driver, is not added to another driver of the net, and chooses its rising or falling delay from the whole vector rather than bit by bit (IEEE 1800-2023 Section 10.3.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_decl_assign_delay_is_driver_delay.expected
*/
// IEEE 1800-2023 §10.3.3: a delay written in a net declaration that also has
// an assignment belongs to that continuous assignment; it is not a net delay,
// so it is not added to the delay of other drivers of the net. And the rising
// and falling delays of such an assignment to a vector net are not applied to
// the bits one by one: the vector rule chooses one delay from the change of
// the whole value (nonzero to zero falls, any other change rises).
//
// The wired-OR net nd has two drivers: its declaration assignment from a,
// with the delays (3, 7), and "assign #2 nd = b". Its value is a | b, so
// while one driver gives 0000 the net shows the other one.
//   t=10 b -> 0101: nd at 12, after the 2 of its own driver only; if the
//                   (3, 7) of the declaration were a net delay, at 15 or later
//   t=20 b -> 0000: nd at 22
//   t=30 a -> 0011: nd at 33 (rising 3)
//   t=40 a -> 0101: one change at 43 (rising: nonzero to nonzero); bit by
//                   bit, bit 2 would rise at 43 and bit 1 fall at 47, so nd
//                   would show 0111 in between
//   t=50 a -> 0000: nd at 57 (falling 7)
//
// Icarus Verilog 13.0 takes the falling delay for 0011 -> 0101, where one
// bit falls but the value stays nonzero, and changes nd only at 47.

`timescale 1ns/1ns
module test_net_decl_assign_delay_is_driver_delay;
  logic [3:0] a = 4'b0000, b = 4'b0000;
  wor [3:0] #(3, 7) nd = a;

  assign #2 nd = b;

  always @(nd) if ($time >= 10) $display("t=%0t nd=%b", $time, nd);

  initial begin
    #10 b = 4'b0101;
    #10 b = 4'b0000;
    #10 a = 4'b0011;
    #10 a = 4'b0101;
    #10 a = 4'b0000;
    #10 $finish;
  end
endmodule
