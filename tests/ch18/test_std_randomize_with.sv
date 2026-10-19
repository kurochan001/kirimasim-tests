/*
:name: test_std_randomize_with
:description: std::randomize() with constraints randomizes the listed scope variables only (IEEE 1800-2023 Section 18.12.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.12.1 18.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_randomize_with.expected
*/
// IEEE 1800-2023 §18.12, §18.12.1: std::randomize(a, b) with { ... } gives
// random values to the variables listed as arguments so that the constraints
// hold, and returns 1; every other variable in the constraints is a state
// variable and keeps its value.

module test_std_randomize_with;
  int a, b, keep;
  int ok;
  int bad = 0;

  initial begin
    keep = 77;
    repeat (50) begin
      ok = std::randomize(a, b) with { a > 0; a < 10; b == a * 3 + keep; };
      if (ok != 1 || !(a > 0 && a < 10) || b != a * 3 + 77 || keep != 77) bad++;
    end
    $display("50 calls: violations=%0d keep=%0d", bad, keep);
  end
endmodule
