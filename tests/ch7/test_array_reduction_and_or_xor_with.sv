/*
:name: test_array_reduction_and_or_xor_with
:description: The and(), or() and xor() reduction methods apply their with clause to each element before reducing (IEEE 1800-2023 Section 7.12.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_and_or_xor_with.expected
*/
// IEEE 1800-2023 §7.12.3: with a with clause, an array reduction method
// reduces the values of the expression for each item instead of the items.
// For '{1, 2, 3}, xor() with (item + 1) is 2 ^ 3 ^ 4 = 5, or() with
// (item + 1) is 7 and and() with (item | 8) is 8; without the clause the
// results are 0, 3 and 0.

module test_array_reduction_and_or_xor_with;
  int a[] = '{1, 2, 3};

  initial begin
    $display("xor() = %0d, xor() with (item + 1) = %0d", a.xor(), a.xor() with (item + 1));
    $display("or() = %0d, or() with (item + 1) = %0d", a.or(), a.or() with (item + 1));
    $display("and() = %0d, and() with (item | 8) = %0d", a.and(), a.and() with (item | 8));
  end
endmodule
