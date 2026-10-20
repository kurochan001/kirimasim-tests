/*
:name: test_clocking_two_blocks_one_output
:description: A variable that is an output of a posedge and a negedge clocking block takes the value most recently driven by either, only in the cycles where a drive occurs, and a clocking block on edge drives at both edges (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.2 14.6 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_two_blocks_one_output.expected
*/
// IEEE 1800-2023 §14.16.2: j is an output of pe, on the rising clock, and of
// ne, on the falling clock. Each drive sets j at the edge of its block, so j
// follows the last drive of either block; at 20 nothing drives j, and it
// keeps its value. A clocking block on edge clk is the same as the pair: k,
// its output, is driven at each edge. The rising edges come at 5, 15, 25 and
// 35, the falling ones at 10, 20 and 30. The changes after 0 are printed at
// the end.

module test_clocking_two_blocks_one_output;
  logic clk = 0;
  logic [3:0] j = 0, k = 0;
  string log_j = "", log_k = "";

  always #5 clk = ~clk;

  clocking pe @(posedge clk);
    output j;
  endclocking

  clocking ne @(negedge clk);
    output j;
  endclocking

  clocking e @(edge clk);
    output k;
  endclocking

  always @(j) if ($time > 0) log_j = {log_j, $sformatf(" %0d:%0d", $time, j)};
  always @(k) if ($time > 0) log_k = {log_k, $sformatf(" %0d:%0d", $time, k)};

  initial begin
    @(pe) pe.j <= 1;     // 5
    @(ne) ne.j <= 2;     // 10
    @(pe) pe.j <= 3;     // 15
    @(ne);               // 20: no drive
    @(pe) pe.j <= 4;     // 25
  end

  initial begin
    @(e) e.k <= 7;       // 5
    @(e) e.k <= 8;       // 10
    @(e) e.k <= 9;       // 15
  end

  initial begin
    #36 $display("j changes:%s", log_j);
    $display("k changes:%s", log_k);
    $finish;
  end
endmodule
