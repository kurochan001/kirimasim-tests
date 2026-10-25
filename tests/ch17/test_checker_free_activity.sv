/*
:name: test_checker_free_activity
:description: A free checker variable on the left-hand side of an assignment is inactive, a packed vector is inactive as a whole while the elements of an unpacked array are separate, a non-free variable is inactive, and the implicitly clocked variable of an empty assume set stays constant within a time step (IEEE 1800-2023 Section 17.7.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2 17.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_free_activity.expected
*/
// IEEE 1800-2023 17.7.2: a free checker variable is inactive if it appears on
// the left-hand side of a checker variable assignment and active otherwise, and
// the activity is for each singular element: a packed vector is inactive as a
// whole when one of its bits is assigned, while the elements of an unpacked
// array are separate. Non-free checker variables and formals are always
// inactive. So p, which is assigned only in bit 0, keeps its other bits and its
// bit 0 toggles from its initial 5 to 4, 5 and 4 at the clock edges at 5, 15
// and 25. u[0] is inactive and toggles from 0 to 1, 0 and 1. The non-free nf
// adds 3 at each edge. The checker has no assume statement, so its assume set
// is empty and z is implicitly clocked: it may be updated once in a time step
// and then stays constant to the end of that step.

`timescale 1ns/1ns

checker free_activity(input logic clk, output logic [3:0] packed_q,
                      output logic u0, output int nonfree_n, output int same);
  // Only bit 0 of the packed vector is assigned, so the whole vector is
  // inactive and bits 3 to 1 keep their values.
  rand bit [3:0] p = 4'd5;
  always_ff @(posedge clk) p[0] <= ~p[0];
  assign packed_q = p;

  // The elements of the unpacked array are separate: element 0 is assigned
  // and so inactive, while element 1 is active.
  rand bit u[0:1] = '{1'b0, 1'b0};
  always_ff @(posedge clk) u[0] <= ~u[0];
  assign u0 = u[0];

  // A non-free checker variable is always inactive.
  int nf = 0;
  always_ff @(posedge clk) nf <= nf + 3;
  assign nonfree_n = nf;

  // Empty assume set: z is implicitly clocked and may be updated once in a
  // time step, then it stays constant to the end of the time step.
  rand bit [7:0] z;
  bit [7:0] first = 8'd0;
  a_same: assert property (@(posedge clk) 1'b1)
    begin
      first = z;
      if (z != first) same = same + 1;
    end
endchecker : free_activity

module test_checker_free_activity;
  logic clk = 1'b0;
  logic [3:0] packed_q;
  logic u0;
  int nonfree_n, same;

  always #5 clk = ~clk;      // rising edges at 5, 15 and 25

  free_activity u(.clk(clk), .packed_q(packed_q), .u0(u0),
                  .nonfree_n(nonfree_n), .same(same));

  initial begin
    #31 $display("packed=%b u0=%b nonfree=%0d same=%0d",
                 packed_q, u0, nonfree_n, same);
    $finish;
  end
endmodule
