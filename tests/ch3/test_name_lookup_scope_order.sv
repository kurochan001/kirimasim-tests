/*
:name: test_name_lookup_scope_order
:description: A simple name is looked up in the nested scopes with their imports first, then in the compilation-unit scope with its imports, and only then, for subroutine names, in the instance hierarchy (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 23.9 23.8 26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_name_lookup_scope_order.expected
*/
// IEEE 1800-2023 §3.12.1: a referenced identifier is searched first in the
// nested scopes (§23.9), with the names that package imports (§26.3) make
// visible there, then in the part of the compilation-unit scope before the
// reference, with its imports, and last in the instance hierarchy (§23.8),
// where a subroutine name is looked for in the enclosing modules.
// h is declared in the compilation unit, in the module and in a named block:
// each reference sees the nearest one. g is only in the compilation unit, so
// a function of the module reads that one. k comes from wildcard imports in
// both the module (10) and the compilation unit (20): the module import is
// in a nested scope and wins. j is imported only into the compilation unit.
// The child calls pick, which the compilation unit (100) and the parent
// module (200) both declare: the compilation-unit function is found before
// the hierarchy. It also calls only_in_parent, found only by the upward
// search in the parent module.
// Icarus Verilog 13.0 resolves pick in the parent module (pick=200), and the
// release 5.052 of Verilator does not find only_in_parent in the parent
// module.

package name_lookup_module_pkg;
  int k = 10;
endpackage

package name_lookup_unit_pkg;
  int k = 20;
  int j = 30;
endpackage

import name_lookup_unit_pkg::*;

int g = 1;
int h = 2;

function automatic int pick();
  return 100;
endfunction

module name_lookup_child(output int from_pick, output int from_parent);
  initial begin
    from_pick = pick();
    from_parent = only_in_parent();
  end
endmodule

module test_name_lookup_scope_order;
  import name_lookup_module_pkg::*;
  int h = 5;
  int from_pick, from_parent;

  function automatic int read_g();
    return g;
  endfunction

  function automatic int pick();
    return 200;
  endfunction

  function automatic int only_in_parent();
    return 300;
  endfunction

  name_lookup_child c(.from_pick(from_pick), .from_parent(from_parent));

  initial begin
    begin : blk
      int h = 9;
      $display("block h=%0d", h);
    end
    $display("module h=%0d unit h=%0d g=%0d", h, $unit::h, read_g());
    $display("k=%0d j=%0d", k, j);
    #1 $display("child: pick=%0d only_in_parent=%0d", from_pick, from_parent);
  end
endmodule
