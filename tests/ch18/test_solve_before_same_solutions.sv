/*
:name: test_solve_before_same_solutions
:description: solve before changes only the probability of the solutions, not which ones are legal, so every result still meets the constraints and randomize does not fail (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.9 18.5.6 18.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_solve_before_same_solutions.expected
*/
// IEEE 1800-2023 §18.5.9: solve s before d makes s 0 or 1 with equal
// probability, but the legal combinations stay those of s -> d == 0 (18.5.6),
// and a solve before constraint cannot make the solver fail. In c2 the order
// asks for y before x, but x can only be 0, and a solver may take it first as
// long as the outcome is the same. The test checks 50 results.

class C;
  rand bit s;
  rand bit [1:0] d;
  rand bit [3:0] x, y;
  constraint c { s -> d == 0; }
  constraint order { solve s before d; }
  constraint c2 { x == 0; x < y; solve y before x; }
endclass

module test_solve_before_same_solutions;
  C obj = new();
  int ok = 0, failed = 0;

  initial begin
    repeat (50) begin
      if (!obj.randomize()) failed++;
      else if ((!obj.s || obj.d == 0) && obj.x == 0 && obj.y > 0) ok++;
    end
    $display("%0d results met the constraints, %0d calls failed", ok, failed);
  end
endmodule
