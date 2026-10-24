/*
:name: test_illegal_array_pattern_default_not_castable
:description: the value of a default key in an array assignment pattern has to be castable to the element type (IEEE 1800-2023 Section 10.9.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default value 5, an int, is given for the elements of hs, which are class handles
:expected_stderr_regex: test_illegal_array_pattern_default_not_castable\.sv:35:
*/
// IEEE 1800-2023 §10.9.1: a default:value applies to the elements not set by
// an index or type key, and for elements that are not arrays or structures
// the value is evaluated as an assignment to each element and shall be
// castable to its type. null for class handles, 3 for real elements and 2.5
// for int elements are castable, which is legal; the int 5 cannot be cast to a
// class handle.
// Icarus Verilog 13.0 gives syntax errors also on the legal patterns with a
// default key, so its error does not count.

class obj_c;
endclass

module test_illegal_array_pattern_default_not_castable;
  obj_c hs [2];
  real rs [2];
  int is [2];

  initial begin
    hs = '{default: null};
    rs = '{default: 3};
    is = '{default: 2.5};
    hs = '{default: 5};   // illegal: an int is not castable to a class handle
    $display("%p %p", rs, is);
  end
endmodule
