/*
:name: test_illegal_constraint_foreach_dimensions
:description: The number of loop variables of a foreach constraint shall not exceed the number of dimensions of the array, packed ones included, so three loop variables for an array with one unpacked and one packed dimension are an error (IEEE 1800-2023 Section 18.5.7.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: foreach (a[i, j, k]) gives three loop variables to the array a, which has two dimensions
:expected_stderr_regex: test_illegal_constraint_foreach_dimensions\.sv:27:
*/
// IEEE 1800-2023 §18.5.7.1: each loop variable of a foreach constraint
// corresponds to one dimension of the array, packed or unpacked, and the
// number of loop variables shall not exceed the number of dimensions. The
// array a has two: the unpacked [4] and the packed [3:0] of its elements
// (the numbering of 20.7), so a[i, j] would still be legal. The constraint
// ok iterates over the unpacked dimension with the one loop variable i and is
// legal. The constraint bad names the three loop variables i, j and k and is
// illegal.

class c_foreach;
  rand bit [3:0] a[4];

  constraint ok { foreach (a[i]) a[i] < 4'hf; }
  constraint bad { foreach (a[i, j, k]) a[i] == j; }   // illegal: too many
endclass

module test_illegal_constraint_foreach_dimensions;
  c_foreach o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
