/*
:name: test_assignment_extension_steps
:description: An assignment first sizes its right-hand side by the expression size rules and then extends it to the target, with sign extension only when the right-hand side is signed (IEEE 1800-2023 Section 11.8.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8.3 11.6.1 11.8.1 11.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_extension_steps.expected
*/
// IEEE 1800-2023 §11.8.3: to evaluate an assignment, the size of the
// right-hand side is determined by the rules of 11.6, and it is then
// extended, with sign extension if and only if its type is signed (11.8.1,
// 11.8.2). A signed 4-bit -8 fills the upper bits of the 8-bit target with
// ones; the same bits unsigned, or cast to unsigned, are zero-extended. In
// sm + um one operand is unsigned, so the sum is unsigned and its operands
// are zero-extended to the 8 bits of the context before they are added.

module test_assignment_extension_steps;
  logic signed [3:0] sm = 4'sb1000;
  logic [3:0] um = 4'b0001;
  logic [7:0] r1, r2, r3, r4;

  initial begin
    r1 = sm;
    r2 = 4'b1000;
    r3 = $unsigned(sm);
    r4 = sm + um;
    $display("%b %b %b %b", r1, r2, r3, r4);
  end
endmodule
