/*
:name: test_illegal_extern_constraint_other_scope
:description: An external constraint block in another scope than the declaration of its class is an error (IEEE 1800-2023 Section 18.5.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the external constraint block for the class of package ecs_pkg is declared in a module, not in the package
:expected_stderr_regex: test_illegal_extern_constraint_other_scope\.sv:33:
*/
// IEEE 1800-2023 §18.5.1: an external constraint block has to be in the same
// scope as the declaration of its class, after that declaration. ecs_obj is
// declared in the package ecs_pkg, but the block that completes its
// prototype c_pos is written in the module, after the package, naming the
// class with the package scope (ecs_pkg::ecs_obj::c_pos). The prototype is in
// the implicit form, so without a valid block it would only be an empty
// constraint (no error); the block in the wrong scope is the only error.
// Icarus Verilog 13.0 does not support external constraint blocks, and the
// 5.052 release of Verilator does not support a block for a class of a
// package, so the errors they report on that line do not count.

package ecs_pkg;
  class ecs_obj;
    rand int v;
    constraint c_pos;
  endclass
endpackage

module test_illegal_extern_constraint_other_scope;
  constraint ecs_pkg::ecs_obj::c_pos { v > 0; }   // illegal: not in ecs_pkg

  ecs_pkg::ecs_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
