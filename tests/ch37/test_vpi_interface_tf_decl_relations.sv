/*
:name: test_vpi_interface_tf_decl_relations
:description: the extern and extern forkjoin declarations of an interface are interface tf decls that lead back to the interface through vpiInstance and iterate the function or tasks that modules define for them, the forkjoin task once for each module that defines it (IEEE 1800-2023 Sections 37.6 and 37.8)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.6 37.8 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interface_tf_decl_relations.c
:expected_stdout: @test_vpi_interface_tf_decl_relations.expected
*/
// IEEE 1800-2023 §25.7: an interface can declare a subroutine with extern,
// to be defined in a module connected to it, and, §25.7.4, a task with
// extern forkjoin, which several connected modules may define. §37.6: an
// interface iterates such declarations, interface tf decls, and each leads
// back to the interface through vpiInstance. §37.8: an interface tf decl
// has the access type vpiExternAcc or vpiForkJoinAcc and iterates the tasks
// (vpiTask) and functions (vpiFunction) that implement it; for an access
// type of vpiForkJoinAcc this can give more than one task, one from each
// module instance that defines it (detail 1). In bus, get_id is defined by
// the module instance da only, and tick by da and db. The application prints
// each declaration of bus and of q, an interface without such declarations,
// with its access type, the names of its functions and tasks, whether two
// tasks are different objects, and whether vpiInstance gives the interface.
// The output is printed from a cbStartOfSimulation callback. The VPI headers
// of Icarus Verilog 13.0 lack vpiInterfaceTfDecl, and Verilator 5.052 does
// not support extern functions.

interface test_vpi_interface_tf_decl_relations_bus;
  int hits = 0;

  extern function int get_id();
  extern forkjoin task tick();
endinterface

interface test_vpi_interface_tf_decl_relations_quiet;
  int v = 0;
endinterface

module test_vpi_interface_tf_decl_relations_dev_a(test_vpi_interface_tf_decl_relations_bus b);
  function int b.get_id();
    return 7;
  endfunction

  task b.tick();
    b.hits += 1;
  endtask
endmodule

module test_vpi_interface_tf_decl_relations_dev_b(test_vpi_interface_tf_decl_relations_bus b);
  task b.tick();
    b.hits += 10;
  endtask
endmodule

module test_vpi_interface_tf_decl_relations;
  test_vpi_interface_tf_decl_relations_bus bus();
  test_vpi_interface_tf_decl_relations_quiet q();
  test_vpi_interface_tf_decl_relations_dev_a da(bus);
  test_vpi_interface_tf_decl_relations_dev_b db(bus);
endmodule
