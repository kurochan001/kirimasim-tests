/*
:name: test_sequence_operator_precedence
:description: Sequence operators bind by the precedence of Table 16-1: ## before throughout, throughout before and, and before or (IEEE 1800-2023 Section 16.9.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.1 16.9.7 16.9.5 16.9.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_operator_precedence.expected
*/
// IEEE 1800-2023 §16.9.1 (Table 16-1): ## binds tighter than throughout,
// throughout tighter than and, and and tighter than or. So x ##1 y or z is
// (x ##1 y) or z, x and y or z is (x and y) or z, and x throughout y ##1 z is x
// throughout (y ##1 z), where x has to hold at the tick of z too (16.9.9). The
// vectors of x, y and z at twelve ticks are chosen so that the other
// groupings would give other counts: 3 for x ##1 (y or z), 4 for x and (y or
// z) and 2 for (x throughout y) ##1 z. Each cover property counts the attempts
// that match.
//
// With Verilator 5.052, which runs cover statements only when built with
// --coverage-user, the throughout property counts 2, as if ## bound less
// tightly than throughout.

`timescale 1ns/1ns

module test_sequence_operator_precedence;
  logic clk = 0, x = 0, y = 0, z = 0;
  logic [2:0] vec [1:12] = '{3'b001, 3'b100, 3'b010, 3'b110, 3'b000, 3'b000, 3'b110,
                             3'b001, 3'b110, 3'b101, 3'b000, 3'b000};
  int n_delay_or = 0, n_and_or = 0, n_throughout = 0;

  always #5 clk = ~clk;

  initial begin
    foreach (vec[k]) begin
      {x, y, z} = vec[k];
      #10;
    end
    $display("x ##1 y or z: %0d", n_delay_or);
    $display("x and y or z: %0d", n_and_or);
    $display("x throughout y ##1 z: %0d", n_throughout);
    $finish;
  end

  c_delay_or: cover property (@(posedge clk) x ##1 y or z) n_delay_or++;
  c_and_or: cover property (@(posedge clk) x and y or z) n_and_or++;
  c_throughout: cover property (@(posedge clk) x throughout y ##1 z) n_throughout++;
endmodule
