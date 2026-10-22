/*
:name: test_assoc_count_expression_types
:description: Count method types are checked independently of traversal method support (IEEE 1800-2023 Section 7.9.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.1 20.6.1 20.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_count_expression_types.expected
*/
// Measure the method expression, not a variable receiving its value. Keep
// this separate from exists/traversal queries to isolate their support.

module test_assoc_count_expression_types;
  int a[int];
  initial begin
    $display("types=%s,%s bits=%0d,%0d", $typename(a.num()), $typename(a.size()),
             $bits(a.num()), $bits(a.size()));
    $display("empty=%0d,%0d", a.num(), a.size());
    a[-10] = 1; a[400] = 2; a[99999] = 3;
    $display("present=%0d,%0d", a.num(), a.size());
    a.delete();
    $display("cleared=%0d,%0d", a.num(), a.size());
  end
endmodule
