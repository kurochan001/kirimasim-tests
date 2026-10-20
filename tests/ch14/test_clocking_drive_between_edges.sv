/*
:name: test_clocking_drive_between_edges
:description: A synchronous drive executed between clocking events evaluates its right-hand side at once and drives at the next clocking event, and ##(expression) between events waits for that many clocking events (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 14.11 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_drive_between_edges.expected
*/
// IEEE 1800-2023 §14.16: a drive that executes at a time without a clocking
// event does not block, evaluates its right-hand side at once, and drives as
// if it had executed at the next clocking event. The drive at 3 takes r = 1,
// so v is 1 from the edge at 5 although r has become 2. §14.11: ##(n + 1)
// with the constant n = 1, executed at 7, waits for two clocking events of
// the default clocking (14.12), at 15 and 25, the first one after a fraction
// of a cycle. A drive at 25, where the clocking event has occurred, takes
// effect at 25.

module test_clocking_drive_between_edges;
  logic clk = 0;
  int r = 1, v = 0;
  localparam int n = 1;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output v;
  endclocking

  initial begin
    #3 cb.v <= r;
    r = 2;
    #4 $display("t=%0d: v=%0d", $time, v);
    ##(n + 1);
    $display("t=%0d: after ##(n + 1)", $time);
    cb.v <= r;
    #1 $display("t=%0d: v=%0d", $time, v);
    $finish;
  end
endmodule
