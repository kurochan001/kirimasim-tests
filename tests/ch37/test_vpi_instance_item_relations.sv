/*
:name: test_vpi_instance_item_relations
:description: From a module instance, each instance-item iteration of the 37.10 model (task func, net, array net, variables, vpiReg, vpiRegArray, vpiMemory, named event, named event array, vpiParameter, spec param, vpiTypedef, assertion, class defn, program, program array) gives exactly the items of that kind declared in it, and vpiInstance of each item gives that instance (IEEE 1800-2023 Section 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_instance_item_relations.c
:expected_stdout: @test_vpi_instance_item_relations.expected
*/
// IEEE 1800-2023 §37.10: an instance has a one-to-many relation to each kind
// of instance item, traversed with vpi_iterate and the type named in the
// diagram (vpiTaskFunc, vpiNet, vpiArrayNet, vpiVariables, vpiNamedEvent,
// vpiNamedEventArray, vpiSpecParam, vpiAssertion, vpiClassDefn, vpiProgram,
// vpiProgramArray) or by its tag (vpiReg for logic variables, vpiRegArray and
// vpiMemory for array variables, vpiParameter, vpiTypedef). Every item has a
// one-to-one relation back to the instance, vpiInstance, which gives the
// immediate instance it is in (detail 3), here m.ua or m.ub and not the top
// module. vpiMemory gives array variable objects (detail 4), and vpiTypedef
// only types declared with typedef (detail 1), not the anonymous struct type
// of sv_anon. A program can be instantiated in a module (24.3).
// The kinds that could overlap (a net and an array net, a named event and a
// named event array, a logic variable and an array variable) are put in two
// different modules, so that each iteration has one fixed set of items. The
// application prints the names of each set sorted, and the full names of the
// instances that vpiInstance gives for its items.

program ii_prog;
  int pv;
endprogram

module ii_items;
  parameter int P = 4;
  localparam int LP = P + 1;
  specparam SP = 7;
  typedef logic [3:0] nib_t;
  typedef enum {RED, BLUE} col_t;
  wire n1;
  logic v1;
  int v2;
  struct packed {logic a; logic b;} sv_anon;
  event e1;

  task tk;
  endtask

  function int fn;
    return 0;
  endfunction

  a1: assert property (@(posedge v1) v1 |-> v1);

  ii_prog pg();
endmodule

module ii_arrays;
  class ii_cls;
    int m;
  endclass

  wire n2 [0:1];
  logic [7:0] mem [0:3];
  event ea [0:2];

  ii_prog pa [1:0] ();
endmodule

module ii_mid;
  ii_items ua();
  ii_arrays ub();
endmodule

module test_vpi_instance_item_relations;
  ii_mid m();

  initial #1 $vt_items;
endmodule
