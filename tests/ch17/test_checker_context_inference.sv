/*
:name: test_checker_context_inference
:description: Checker formals that default to $inferred_clock and $inferred_disable take the default clocking and default disable iff of the instantiating module (IEEE 1800-2023 Section 17.4)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.4 16.14.7 14.12 16.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_context_inference.expected
*/
// IEEE 1800-2023 §17.4: a checker formal whose default is $inferred_clock or
// $inferred_disable (16.14.7) takes its value from the context of the
// instance when the instance leaves it out. Outside procedural code that
// context is the module's default clocking (14.12) and default disable iff
// (16.15). So the assertion in c1 is clocked by posedge clk and disabled
// while rst is 1: ok is low at the edges at 15, 25 and 35, but rst is
// released at 20, so it fails only at 25 and 35.

checker in_context (logic sig, event clock = $inferred_clock,
                    logic reset = $inferred_disable);
  a1: assert property (@clock disable iff (reset) sig)
    else $display("t=%0d the checked signal is low", $time);
endchecker

module test_checker_context_inference;
  logic clk = 0, rst = 1, ok = 1;

  always #5 clk = ~clk;

  default clocking @(posedge clk);
  endclocking
  default disable iff (rst);

  in_context c1 (ok);

  initial begin
    #10 ok = 0;
    #10 rst = 0;
    #20 ok = 1;
    #10 $finish;
  end
endmodule
