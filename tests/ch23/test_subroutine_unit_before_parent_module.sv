/*
:name: test_subroutine_unit_before_parent_module
:description: A task or function name is first looked up in the scopes around the call, then in the whole compilation unit, and only then in the parent instances, so a compilation-unit function wins over a function of the same name in the parent module (IEEE 1800-2023 Section 23.8.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.8.1 23.8 3.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_unit_before_parent_module.expected
*/
// IEEE 1800-2023 §23.8.1: a task or function name is resolved by the upward
// rules of §23.8, but after step a), the scopes that enclose the call in its
// module, the whole compilation unit of the call (§3.12.1) is searched, and
// only then step b), the scopes of the parent instances. which_f is declared
// in the compilation unit (returns 1), in the parent module (returns 2) and
// in the generate block g of the child (returns 3); only_parent is declared
// only in the parent module (returns 4).
//   the child module calls which_f(): not in the child, found in the
//      compilation unit before the parent: 1;
//   the child calls only_parent(): not in the child or the compilation
//      unit, found in the parent: 4;
//   the block g of the child calls which_f(): found in g itself: 3.
// Searching the parent before the compilation unit would give 2, which is
// what Icarus Verilog 13.0 prints; Verilator 5.052 does not find
// only_parent in the parent module.

function automatic int which_f();
  return 1;
endfunction

module subroutine_unit_child;
  initial #1 $display("child: which_f()=%0d only_parent()=%0d", which_f(), only_parent());

  if (1) begin : g
    function automatic int which_f();
      return 3;
    endfunction

    initial #2 $display("child.g: which_f()=%0d", which_f());
  end
endmodule

module test_subroutine_unit_before_parent_module;
  function automatic int which_f();
    return 2;
  endfunction

  function automatic int only_parent();
    return 4;
  endfunction

  subroutine_unit_child c();
endmodule
