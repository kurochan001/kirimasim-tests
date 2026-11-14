/*
:name: test_illegal_assoc_delete_all_result_as_value
:description: the associative array method delete() returns void also when it is called without an index, so a call of it cannot be used as a value; assigning its result is an error (IEEE 1800-2023 Section 7.9.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of the void method delete() of the associative array m, called without an index, is assigned to the variable n
:expected_stderr_regex: test_illegal_assoc_delete_all_result_as_value\.sv:39:
*/
// IEEE 1800-2023 §7.9.2: the associative array method delete() is declared
// with the return type void, with or without its optional index argument. By
// §13.4.1 a call of a function can be used as an expression only when the
// function is not void; a call of a void function is a statement, and it has
// no value to use.
// The legal design calls m.delete() as a statement, which removes all the
// entries, and prints the number of entries before and after: 3 0. The last
// statement uses a call of delete() without an index as the source of an
// assignment to the int variable n. The form with an index is checked by
// test_illegal_assoc_delete_index_result_as_value.
// Icarus Verilog 13.0 does not support associative arrays with an index
// type and reports errors on their declaration and uses, which do not count.
// The 5.054 release of Verilator accepts the line and fails only when it
// compiles the C++ code it generates, which does not count.

module test_illegal_assoc_delete_all_result_as_value;
  int m [int];
  int n;
  initial begin
    m[1] = 10;
    m[2] = 20;
    m[3] = 30;
    n = m.num();
    m.delete();
    $display("%0d %0d", n, m.num());
    n = m.delete();   // illegal: delete() returns void
  end
endmodule
