/*
:name: test_vpi_cont_assign_bits_delays
:description: The bits of a vector continuous assignment are scalar cont assign bits with their offset from the LSB and the assignment as parent; value change callbacks on the assignment and on one bit report the changes of each; vpiDelay of a net with two delays is a list operation and with one an expression of that value, and vpi_get_delays on a bufif1 gives its three delays in source order (IEEE 1800-2023 Sections 37.47 and 37.3.4)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.47 37.3.4 38.10 38.36.1 10.3.3 28.16
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_cont_assign_bits_delays.c
:expected_stdout: @test_vpi_cont_assign_bits_delays.expected
*/
// IEEE 1800-2023 §37.47: vpi_iterate(vpiBit) over the continuous assignment
// to the vector cv gives its bits, each a scalar of size 1 (detail 1) whose
// vpiOffset is 0 for the LSB (detail 3) and whose vpiParent is the
// assignment; value change callbacks (38.36.1) can be placed on the
// assignment and on a bit (detail 2). At 1 cv is 0110; the application
// places one callback on the assignment and one on its bit of offset 1; at 2,
// 3 and 4 cv becomes 0100, 1100 and 1110, so the bit changes at 2 and 4. The
// callbacks record the time and the value, and $vt_report prints the record
// at 5, since the order of callbacks within a time step is not fixed.
// §37.3.4: vpiDelay gives the delay written in the source: for the net n2
// declared with two delays an operation with vpiOpType vpiListOp, whose
// operands, the delays, are printed sorted, and for n1 with one delay an
// expression that evaluates to the constant. vpi_get_delays (38.10), with
// the 2 or 3 delays allowed for a primitive, gives the delays of the bufif1
// gb in source order: rise, fall and turn-off (28.16), here in simulation
// time units, 1 ns, the only precision of the design.

`timescale 1ns/1ns

module test_vpi_cont_assign_bits_delays;
  logic [3:0] a4 = 4'b0110, b4 = 4'b0000;
  logic en = 1, din = 1;
  wire [3:0] cv;
  wire #(2, 3) n2;
  wire #4 n1;
  wire t3;

  assign cv = a4 ^ b4;
  assign n2 = din;
  assign n1 = din;
  bufif1 #(1, 2, 3) gb (t3, din, en);

  initial begin
    #1 $vt_setup;
    #1 a4 = 4'b0100;
    #1 b4 = 4'b1000;
    #1 a4 = 4'b0110;
    #1 $vt_report;
  end
endmodule
