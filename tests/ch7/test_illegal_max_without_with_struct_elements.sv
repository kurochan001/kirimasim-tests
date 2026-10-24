/*
:name: test_illegal_max_without_with_struct_elements
:description: the with clause of max() can be omitted only when the relational operators are defined for the element type; an array of unpacked structures needs it (IEEE 1800-2023 Section 7.12.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: max() is called without a with clause on the array r of unpacked structures, for which the relational operators are not defined
:expected_stderr_regex: test_illegal_max_without_with_struct_elements\.sv:40:
*/
// IEEE 1800-2023 §7.12.1: the with clause of min(), max(), unique() and
// unique_index() may be omitted only if the relational operators <, > and ==
// are defined for the element type of the array; without it the method compares
// the elements themselves. max() returns a queue of the element whose with
// expression is the largest.
// The array r has elements of the unpacked structure type rec_t. The legal call
// has the int with expression item.key, and the legal design prints what it
// returns: 1 3. The last call has no with clause.
// The relational operators of 11.4.4 compare integral or real operands, and
// none of them is defined for an unpacked structure.
// Icarus Verilog 13.0 does not support unpacked structures or the with clause
// of array methods and reports errors on them, which do not count. The 5.052
// release fails when it compiles the C++ code it generates for these calls, the
// legal one included, which does not count.

module test_illegal_max_without_with_struct_elements;
  typedef struct { int key; int val; } rec_t;
  rec_t r [3];
  rec_t q [$];
  int qi [$];
  initial begin
    r[0].key = 3;
    r[1].key = 1;
    r[2].key = 2;
    q = r.max with (item.key);
    $display("%0d %0d", q.size(), q[0].key);
    q = r.max;   // illegal: no with clause for unpacked structure elements
  end
endmodule
