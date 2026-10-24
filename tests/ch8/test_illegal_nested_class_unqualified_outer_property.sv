/*
:name: test_illegal_nested_class_unqualified_outer_property
:description: a nested class has no implicit handle of its outer class, so it cannot name a non-static outer property without a handle (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method of the nested class inner_c names the non-static property count of outer_c without a handle
:expected_stderr_regex: test_illegal_nested_class_unqualified_outer_property\.sv:46:
*/
// IEEE 1800-2023 §8.23: a nested class may name the static properties and
// methods and the parameters of its containing class without qualification,
// and has the access rights of a method of that class, so it reaches local
// members through a handle; but there is no implicit this of the outer
// class, and a non-static property or method of it is only reachable through
// a handle. inner_c::sum calls the static twice with the local parameter
// STEP and reads count, peek() and the local secret through its argument h,
// which is legal; inner_c::own_count reads count without a handle.
// Icarus Verilog 13.0 does not support nested classes. Verilator 5.052 accepts
// the design and writes C++ code that does not compile.

class outer_c;
  localparam int STEP = 3;
  static int total;
  int count = 1;
  local int secret = 7;

  static function int twice(int v);
    return 2 * v;
  endfunction

  function int peek();
    return secret + 1;
  endfunction

  class inner_c;
    function int sum(outer_c h);
      total = twice(STEP);
      return total + h.count + h.peek() + h.secret;
    endfunction

    function int own_count();
      return count;   // illegal: no implicit handle of the outer object
    endfunction
  endclass
endclass

module test_illegal_nested_class_unqualified_outer_property;
  initial $display("done");
endmodule
