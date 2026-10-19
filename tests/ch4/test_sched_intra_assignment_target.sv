/*
:name: test_sched_intra_assignment_target
:description: With an intra-assignment timing control the right-hand side is evaluated first; a blocking assignment picks its target when it resumes, a nonblocking one when it executes (IEEE 1800-2023 Section 4.9.3)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.3 4.9.4 9.4.5 10.4.1 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_intra_assignment_target.expected
*/
// IEEE 1800-2023 §9.4.5: an intra-assignment delay or event control evaluates
// the right-hand side before the wait and assigns after it. §4.9.3, §10.4.1:
// for a blocking assignment, an index in the target is evaluated when the
// process resumes. §4.9.4, §10.4.2: for a nonblocking assignment it is
// evaluated together with the right-hand side, when the statement executes.
// A repeat count is evaluated once at the start, and a count of zero or less
// assigns at once.

module test_sched_intra_assignment_target;
  int b = 5;
  int i = 0;
  int x, y;
  int ab[2];
  int an[2];
  logic clk = 0;
  int r3, r0;

  always #5 clk = ~clk;   // posedges at 5, 15, 25

  initial x = #2 b;        // reads b (5) at time 0
  initial y <= #2 b;       // reads b (5) at time 0
  initial ab[i] = #2 9;    // index read at time 2, when i is 1
  initial an[i] <= #2 9;   // index read at time 0, when i is 0
  initial begin
    #1;
    b = 7;
    i = 1;
    #9;
    b = 8;                               // time 10: after r3 read b
  end

  int n = 3;
  initial begin
    #2;
    r3 = repeat (n) @(posedge clk) b;   // reads b (7) and n (3) at time 2
  end
  initial begin
    #3;
    n = 1;                               // too late to change the count
  end
  initial begin
    #3;
    r0 = repeat (0) @(posedge clk) 11;  // a count of 0: no wait
    $display("t3 r0=%0d", r0);
  end

  initial begin
    #4;
    $display("t4 x=%0d y=%0d", x, y);
    $display("t4 ab[0]=%0d ab[1]=%0d", ab[0], ab[1]);
    $display("t4 an[0]=%0d an[1]=%0d", an[0], an[1]);
    #20;
    $display("t24 r3=%0d", r3);
    #2;
    $display("t26 r3=%0d", r3);
    $finish;
  end
endmodule
