/*
:name: test_bind_instance_name_over_module_name_and_placements
:description: a bind whose target names both an instance and a module binds only into that instance, a bind to a module name alone binds into every instance, and bind directives work in a module, in an interface and in the compilation-unit scope (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bind_instance_name_over_module_name_and_placements.expected
*/
// IEEE 1800-2023 §23.11: a bind directive may be written in a module, in an
// interface or in a compilation-unit scope. Its first form names a module
// (or interface) and inserts the instantiation into every instance of it;
// the second form names one instance. When the target of the second form
// resolves both to an instance name and to a module name, the binding is
// done only into that instance.
//
// Every bound instance of probe stores its own hierarchical name (%m) in an
// associative array of a package at time 0; at time 1 top prints the keys,
// which a string index orders lexicographically (7.8.2), so the order in
// which the probes start does not matter.
// - In top, u_a is the name of an instance of the module other and also the
//   name of a module, of which top has the instance x: bind u_a binds only
//   into top.u_a, and top.x gets no probe.
// - In top, bind leaf_m names a module only, so both of its instances, m1
//   and m2, get a probe.
// - The bind of leaf_i is written in the interface ifc (instantiated in top)
//   and the bind of leaf_u in the compilation-unit scope; their instances
//   k1 and w1 get a probe.
// Icarus Verilog 13.0 does not support bind. Verilator 5.054 gives the other
// lines, but binds u_a into top.x, the instance of the module u_a, instead
// of into the instance top.u_a.

package bind_log_pkg;
  bit seen[string];
endpackage

module probe;
  initial bind_log_pkg::seen[$sformatf("%m")] = 1;
endmodule

module u_a;
endmodule

module other;
endmodule

module leaf_m;
endmodule

module leaf_i;
endmodule

module leaf_u;
endmodule

bind leaf_u probe p_unit();

interface ifc;
  bind leaf_i probe p_ifc();
endinterface

module test_bind_instance_name_over_module_name_and_placements;
  ifc i0();
  other u_a();
  u_a x();
  leaf_m m1(), m2();
  leaf_i k1();
  leaf_u w1();

  bind u_a probe p_inst();
  bind leaf_m probe p_mod();

  initial begin
    #1;
    foreach (bind_log_pkg::seen[k]) $display("probe %s", k);
    $display("%0d probes", bind_log_pkg::seen.num());
  end
endmodule
