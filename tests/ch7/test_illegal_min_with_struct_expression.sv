/*
:name: test_illegal_min_with_struct_expression
:description: when min() has a with clause, the relational operators have to be defined for the type of its expression; an unpacked structure expression is an error (IEEE 1800-2023 Section 7.12.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the with expression of min() on the array r is the unpacked structure item, for which the relational operators are not defined
:expected_stderr_regex: test_illegal_min_with_struct_expression\.sv:40:
*/
// IEEE 1800-2023 §7.12.1: for min(), max(), unique() and unique_index(), when a
// with clause is given, the relational operators <, > and == shall be defined
// for the type of its expression. min() returns a queue of the element whose
// with expression is the smallest.
// The array r has elements of the unpacked structure type rec_t. The legal call
// has the int with expression item.key, and the legal design prints the size of
// the queue and the key of its element: 1 1. The last call has the with
// expression item, an unpacked structure.
// The relational operators of 11.4.4 compare integral or real operands, and
// none of them is defined for an unpacked structure.
// Icarus Verilog 13.0 does not support unpacked structures or the with clause
// of array methods and reports errors on them, which do not count. The 5.052
// release fails when it compiles the C++ code it generates for these calls, the
// legal one included, which does not count.

module test_illegal_min_with_struct_expression;
  typedef struct { int key; int val; } rec_t;
  rec_t r [3];
  rec_t q [$];
  int qi [$];
  initial begin
    r[0].key = 3;
    r[1].key = 1;
    r[2].key = 2;
    q = r.min with (item.key);
    $display("%0d %0d", q.size(), q[0].key);
    q = r.min with (item);   // illegal: the with expression is an unpacked structure
  end
endmodule
