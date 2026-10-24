/*
:name: test_illegal_extern_body_outside_class_scope
:description: an out-of-block method declaration has to be in the scope of its class declaration (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24 27.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the out-of-block declaration of sq_c::area is in the generate block g, not in the module scope where sq_c is declared
:expected_stderr_regex: test_illegal_extern_body_outside_class_scope\.sv:(27|31):
*/
// IEEE 1800-2023 §8.24: an out-of-block method declaration shall be declared
// in the same scope as the class declaration, and follow it. sq_c is declared
// in the module, and the out-of-block declaration of its method area in the
// generate block g of that module (27.5), another scope, from which the name
// sq_c is still visible. A tool can report the out-of-block declaration, or
// the prototype that is left without one.
// Icarus Verilog 13.0 does not support out-of-block methods, and its syntax
// error on the out-of-block declaration does not count; Verilator 5.052 accepts
// the design.

module test_illegal_extern_body_outside_class_scope;
  class sq_c;
    int side = 2;
    extern function int area();   // (or reported here)
  endclass

  if (1) begin : g
    function int sq_c::area();   // illegal: not the scope of sq_c
      return side * side;
    endfunction
  end

  initial $display("done");
endmodule
