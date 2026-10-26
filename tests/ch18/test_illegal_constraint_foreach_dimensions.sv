/*
:name: test_illegal_constraint_foreach_dimensions
:description: The number of loop variables of a foreach constraint shall not exceed the number of dimensions of the array, so two loop variables for a one-dimensional array are an error (IEEE 1800-2023 Section 18.5.7.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: foreach (a[i, j]) gives two loop variables to the one-dimensional array a
:expected_stderr_regex: test_illegal_constraint_foreach_dimensions\.sv:25:
*/
// IEEE 1800-2023 §18.5.7.1: each loop variable of a foreach constraint
// corresponds to one dimension of the array, and the number of loop variables
// shall not exceed the number of dimensions. The constraint ok iterates over
// the single dimension of a with the one loop variable i and is legal. The
// constraint bad names the two loop variables i and j for the same
// one-dimensional array and is illegal.

class c_foreach;
  rand bit [3:0] a[4];

  constraint ok { foreach (a[i]) a[i] < 4'hf; }
  constraint bad { foreach (a[i, j]) a[i] == j; }   // illegal: too many
endclass

module test_illegal_constraint_foreach_dimensions;
  c_foreach o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
