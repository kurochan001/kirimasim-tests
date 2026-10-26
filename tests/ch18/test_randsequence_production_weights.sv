/*
:name: test_randsequence_production_weights
:description: A production-list selection probability is proportional to its := weight, an omitted weight is 1, and executing the selected production runs its code block once per call (IEEE 1800-2023 Sections 18.17 and 18.17.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17 18.17.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_production_weights.expected
*/
// IEEE 1800-2023 §18.17.1: main : A := 3 | B := 1 gives A three quarters of
// the choices, so 800 calls give about 600 A and 200 B, and every call
// generates exactly one of them. Executing a randsequence generates the
// production stream and runs the side effects of the code blocks.

module test_randsequence_production_weights;
  int na, nb;

  initial begin
    na = 0;
    nb = 0;
    repeat (800) begin
      randsequence (main)
        main : A := 3 | B := 1;
        A : { na++; };
        B : { nb++; };
      endsequence
    end
    $display("weights 3:1: A in 540..660 %0d, B in 140..260 %0d",
             na >= 540 && na <= 660, nb >= 140 && nb <= 260);
    $display("one production per call: 800 %0d", na + nb == 800);
  end
endmodule
