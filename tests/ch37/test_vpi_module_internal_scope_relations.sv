/*
:name: test_vpi_module_internal_scope_relations
:description: vpiInternalScope of a module iterates its task, its function and its named block, and vpiModule of each of these scopes leads back to the instance; a module without scopes inside has none (IEEE 1800-2023 Section 37.5)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.5 37.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_internal_scope_relations.c
:expected_stdout: @test_vpi_module_internal_scope_relations.expected
*/
// IEEE 1800-2023 §37.5: the tag vpiInternalScope gives the one-to-many
// relation from a module to the scopes it contains, and each scope has the
// one-to-one relation vpiModule back to the module. §37.12: tasks,
// functions and named begin blocks are scopes. s1 and s2 are instances of a
// module with the task t, the function f and the named block blk of an
// initial procedure, and with no other scope; e is an instance of a module
// whose only procedure has no named block. The application prints, for each
// instance, the name and vpiType of each internal scope, sorted, with the
// instance that vpiModule gives for it. The output is printed from a
// cbStartOfSimulation callback, before the procedures run. In Verilator
// 5.052 the iteration gives no scope.

module test_vpi_module_internal_scope_relations_leaf;
  int x;

  task t;
    x = 1;
  endtask

  function int f(input int a);
    return a + 1;
  endfunction

  initial begin : blk
    x = 0;
  end
endmodule

module test_vpi_module_internal_scope_relations_plain;
  logic v;

  initial v = 1'b0;
endmodule

module test_vpi_module_internal_scope_relations;
  test_vpi_module_internal_scope_relations_leaf s1();
  test_vpi_module_internal_scope_relations_leaf s2();
  test_vpi_module_internal_scope_relations_plain e();
endmodule
