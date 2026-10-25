/*
:name: test_illegal_class_index_with_other_class
:description: an associative array with a class index takes objects of that class or of a derived class as indices; an object of an unrelated class is a type check error (IEEE 1800-2023 Section 7.8.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative array m, indexed by the class base_c, is indexed by a handle of the unrelated class other_c
:expected_stderr_regex: test_illegal_class_index_with_other_class\.sv:46:
*/
// IEEE 1800-2023 §7.8.3: the indices of an associative array with a class index
// can be objects of that class or of a class derived from it, and null; any
// other type is illegal and is a type check error.
// The array m, indexed by base_c, is written through a base_c handle, a handle
// of the derived class derived_c and null; the legal design prints the number
// of entries and the entries of the two objects: 3 1 2. The last statement
// indexes m with a handle of other_c, which is not derived from base_c.
// Icarus Verilog 13.0 does not support associative arrays with an index
// type and reports errors on their declarations and uses, which do not
// count.
// The 5.052 release accepts the design and fails only when it compiles
// the C++ code that it generates, which does not count.

module test_illegal_class_index_with_other_class;
  class base_c;
  endclass
  class derived_c extends base_c;
  endclass
  class other_c;
  endclass
  int m [base_c];
  base_c b;
  derived_c d;
  other_c o;
  initial begin
    b = new;
    d = new;
    o = new;
    m[b] = 1;
    m[d] = 2;
    m[null] = 3;
    $display("%0d %0d %0d", m.num(), m[b], m[d]);
    m[o] = 4;   // illegal: an index of an unrelated class
  end
endmodule
