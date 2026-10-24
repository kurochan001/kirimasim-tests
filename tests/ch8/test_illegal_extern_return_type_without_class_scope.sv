/*
:name: test_illegal_extern_return_type_without_class_scope
:description: an out-of-block method whose return type is declared in its class has to name that type with the class scope (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the out-of-block declaration of tag names its return type tag_t, declared inside cell_c, without cell_c::
:expected_stderr_regex: test_illegal_extern_return_type_without_class_scope\.sv:31:
*/
// IEEE 1800-2023 §8.24: when the return type of an out-of-block declaration
// is defined within the class, the class scope resolution operator shall be
// used to name it. code returns cell_c::tag_t, which is legal; the header of
// tag names tag_t alone, and no tag_t is declared outside cell_c.
// Icarus Verilog 13.0 does not support out-of-block methods, and Verilator
// 5.052 accepts the design.

class cell_c;
  typedef bit [2:0] tag_t;
  extern function tag_t code();
  extern function tag_t tag();
endclass

function cell_c::tag_t cell_c::code();
  return 3'd2;
endfunction

function tag_t cell_c::tag();   // illegal: needs cell_c::tag_t
  return 3'd5;
endfunction

module test_illegal_extern_return_type_without_class_scope;
  initial $display("done");
endmodule
