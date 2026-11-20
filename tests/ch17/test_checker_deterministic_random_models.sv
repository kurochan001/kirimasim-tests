/*
:name: test_checker_deterministic_random_models
:description: A checker accepts ordinary deterministic state and random free variables in one model, with initialized and arbitrary constant free variables retaining their values (IEEE 1800-2023 Section 17.1)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.1 17.7 17.7.1 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_deterministic_random_models.expected
*/
// 17.1 B003 permits deterministic and random checker variables. The ordinary
// state below deterministically advances 2,5,8,11,14 on four clock ticks.
// 17.7 B014-B015 and 17.7.2 B005 allow a constant free variable initialized
// with 11 and another with an arbitrary random initializer. Neither constant
// changes. The arbitrary value is never printed or required to differ from
// any other value: only its retention after the first tick is observed.
// This tests the permitted variable kinds, not statistical randomness or
// the separate requirement that formal tools consider all possible values.

`timescale 1ns/1ns

checker mixed_model(input logic clk, output int deterministic_out,
                    output bit fixed_ok, output bit arbitrary_stable);
  int deterministic = 2;
  rand const bit [3:0] fixed_free = 4'd11;
  rand const bit [31:0] arbitrary_free;
  bit [31:0] first_arbitrary;
  bit first = 1;
  bit fixed_good = 1, arbitrary_good = 1;

  always_ff @(posedge clk) begin
    deterministic <= deterministic + 3;
    if (fixed_free != 4'd11) fixed_good <= 0;
    if (first) begin
      first_arbitrary <= arbitrary_free;
      first <= 0;
    end
    else if (arbitrary_free != first_arbitrary) arbitrary_good <= 0;
  end

  assign deterministic_out = deterministic;
  assign fixed_ok = fixed_good;
  assign arbitrary_stable = arbitrary_good;
endchecker

module test_checker_deterministic_random_models;
  logic clk = 0;
  int deterministic;
  bit fixed_ok, stable_ok;
  mixed_model m(clk, deterministic, fixed_ok, stable_ok);

  always #5 clk = ~clk;
  initial begin
    #1 $display("initial deterministic=%0d fixed=%0d", deterministic, fixed_ok);
    #10 $display("after one deterministic=%0d fixed=%0d", deterministic, fixed_ok);
    #26 $display("after four deterministic=%0d fixed=%0d stable=%0d",
                 deterministic, fixed_ok, stable_ok);
    $finish;
  end
endmodule
