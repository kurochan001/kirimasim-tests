/*
:name: test_illegal_extern_argument_type_mismatch
:description: the argument types of an out-of-block method declaration have to match its prototype (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the out-of-block declaration of put declares its argument as byte where the prototype has int
:expected_stderr_regex: test_illegal_extern_argument_type_mismatch\.sv:(25|32):
*/
// IEEE 1800-2023 §8.24: an out-of-block method declaration shall match the
// prototype exactly, except for the class scope before the method name, a
// class scope a return type may need, and default values it may leave out.
// get matches its prototype; the argument of put is int in the prototype and
// byte in the out-of-block declaration. The mismatch can be reported at the
// out-of-block declaration or at the prototype.
// Icarus Verilog 13.0 does not support out-of-block methods.

class store_c;
  int last;
  extern function int get();
  extern function void put(int v);   // (or reported here)
endclass

function int store_c::get();
  return last;
endfunction

function void store_c::put(byte v);   // illegal: argument type differs
  last = v;
endfunction

module test_illegal_extern_argument_type_mismatch;
  store_c s = new;
  initial $display("%0d", s.get());
endmodule
