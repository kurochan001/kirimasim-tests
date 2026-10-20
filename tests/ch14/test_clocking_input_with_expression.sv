/*
:name: test_clocking_input_with_expression
:description: A clocking block input declared with an expression samples that expression, not a signal that has the clockvar's name (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input_with_expression.expected
*/
// IEEE 1800-2023 §14.3: in "input x = loc;" the expression after = is the
// signal that the clockvar x is associated with, so cb.x samples loc, even
// though the module also has a variable named x. With the default input skew
// of 1step (14.13), each clocking event gives cb.x the value loc had just
// before the edge: 00, 11 and 22 at the first three edges.

module test_clocking_input_with_expression;
  logic clk = 1'b0;
  logic [7:0] loc = 8'h00;
  logic [7:0] x = 8'he0;

  always #5 clk = ~clk;
  always @(posedge clk) loc <= loc + 8'h11;
  always @(posedge clk) x <= x + 8'h01;

  clocking cb @(posedge clk);
    input x = loc;
  endclocking

  initial begin
    repeat (3) begin
      @(cb);
      $display("t=%0d cb.x=%h", $time, cb.x);
    end
    $finish;
  end
endmodule
