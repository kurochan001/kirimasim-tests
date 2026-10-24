/*
:name: test_illegal_extern_body_before_class
:description: an out-of-block method declaration has to follow the declaration of its class (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24 8.27
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the out-of-block declaration of early_c::get comes before the declaration of early_c
:expected_stderr_regex: test_illegal_extern_body_before_class\.sv:(24|29):
*/
// IEEE 1800-2023 §8.24: an out-of-block method declaration shall be in the
// same scope as the class declaration and shall follow it. early_c is known
// through a forward typedef (8.27) when the out-of-block declaration of get
// appears, but its class declaration comes only after it. A tool can report
// the out-of-block declaration, or the prototype that is left without one.
// Icarus Verilog 13.0 does not support out-of-block methods, and its syntax
// error on the out-of-block declaration does not count.

typedef class early_c;

function int early_c::get();   // illegal: before the class declaration
  return 1;
endfunction

class early_c;
  extern function int get();   // (or reported here)
endclass

module test_illegal_extern_body_before_class;
  initial $display("done");
endmodule
