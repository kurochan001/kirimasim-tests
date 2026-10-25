/*
:name: test_unit_hierarchical_reference_from_root
:description: A hierarchical name in the compilation-unit scope that does not name a compilation-unit item is a full path from the top of the design, not a name relative to the instance that calls the subroutine holding it (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 23.8 23.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unit_hierarchical_reference_from_root.expected
*/
// IEEE 1800-2023 §3.12.1: items in the compilation-unit scope can hold
// hierarchical references; for upward name referencing (§23.8) the
// compilation-unit scope is like a top-level design element, so a reference
// that is not to a compilation-unit item, or to one imported there, is a
// full path name from the top of the design ($root, §23.3.1).
// The compilation-unit function peek reads probe_point.v. The design has a
// top-level module probe_point with v = 222, and the test module has a child
// instance that is also named probe_point, with v = 111. The test calls
// peek and gets 222: the name starts at the top level, even though the call
// is made from the module that holds the instance probe_point. A module
// function with the same reference reads its own child, 111.

function automatic int peek();
  return probe_point.v;
endfunction

module unit_probe_child;
  int v = 111;
endmodule

module probe_point;
  int v = 222;
endmodule

module test_unit_hierarchical_reference_from_root;
  unit_probe_child probe_point();

  function automatic int peek_local();
    return probe_point.v;
  endfunction

  initial #1 $display("unit function: %0d module function: %0d", peek(), peek_local());
endmodule
