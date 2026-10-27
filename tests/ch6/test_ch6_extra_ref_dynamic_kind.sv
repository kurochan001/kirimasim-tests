/*
:name: test_ch6_extra_ref_dynamic_kind
:description: A dynamic array and a queue are different kinds of array and so are not equivalent, even with the same element type; a ref argument cannot pair them (IEEE 1800-2023 Section 6.22.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.22.2 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ref argument q is a queue of int but the formal a is a dynamic array of int
:expected_stderr_regex: test_ch6_extra_ref_dynamic_kind\.sv:30:
*/
// IEEE 1800-2023 §6.22.2 rule e: dynamic array, associative array and queue
// types are equivalent only when they are the same kind of array and have
// equivalent element types. int[] and int[$] have the same element type but
// differ in kind, so they are nonequivalent. §13.5.2 requires a ref argument
// to be matched with an equivalent data type, so the call on the marked line
// is illegal. A dynamic array actual is accepted and is covered by
// test_ch6_extra_ref_dynamic_equiv.
// Icarus Verilog 13.0 does not support ref ports, so this test has no Icarus
// oracle.

module test_ch6_extra_ref_dynamic_kind;
  task automatic take(ref int a[]);
    a = new[1];
  endtask

  int q[$];
  initial take(q);   // illegal: a queue is not equivalent to a dynamic array
endmodule
