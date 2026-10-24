/*
:name: test_vpi_attribute_parents
:description: Attributes on a module instance, net, net array, variable, named event, specparam, task, gate, statement, operator, initial procedure, sequence, property, concurrent assertion, clocking block, class and constraint are iterated with vpiAttribute from that object, and each attribute leads back to it with vpiParent (IEEE 1800-2023 Section 37.83)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.83 5.12 37.10 37.12 37.31 37.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_attribute_parents.c
:expected_stdout: @test_vpi_attribute_parents.expected
*/
// IEEE 1800-2023 §37.83: instances, nets, net arrays, variables, named events,
// specparams, tasks and functions, primitives, statements, processes,
// operations, concurrent assertions, sequence and property declarations,
// clocking blocks, class definitions and constraints iterate their attributes
// with vpiAttribute, and an attribute leads to the object it belongs to with
// vpiParent; its name is vpiName and its value comes from vpi_get_value().
// §5.12: an attribute instance is attached to the declaration, module item or
// statement it prefixes, or to the operator it follows; the grammar (A.1.4,
// A.1.9) allows one before each of the items below, including a constraint
// inside a class.
//
// Each object carries one attribute of its own with its own value, the net
// w_plain none. From a start-of-simulation callback the application finds
// each object (by name, through the statement of the task t_stmt and its
// right-hand side, through the only process of the module, or through the
// class and constraint iterations) and prints the name and value of each
// attribute of it and whether vpiParent of the attribute is that object.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiAttribute and other constants used
// here, and with --vpi the C++ model that Verilator 5.052 generates does not
// compile, as it refers to a member for the specparam SP that it lacks.

module atr_leaf (input logic p);
endmodule

module test_vpi_attribute_parents;
  logic clk, a, b, v;

  (* a_inst = 1 *) atr_leaf u (.p(a));
  (* a_net = 2 *) wire w;
  wire w_plain;
  (* a_anet = 3 *) wire wa [0:1];
  (* a_var = 4 *) int iv;
  (* a_event = 5 *) event e;
  (* a_spec = 6 *) specparam SP = 7;

  (* a_task = 8 *) task t_attr;
  endtask

  (* a_gate = 9 *) and g1 (w, a, b);

  task t_stmt;
    (* a_stmt = 10 *) v = a + (* a_op = 11 *) b;
  endtask

  (* a_proc = 12 *) initial clk = 1'b0;

  (* a_seq = 13 *) sequence s1;
    @(posedge clk) a ##1 b;
  endsequence

  (* a_prop = 14 *) property p1;
    @(posedge clk) a |-> b;
  endproperty

  (* a_assert = 15 *) a1: assert property (p1);

  (* a_cb = 16 *) clocking cb @(posedge clk);
  endclocking

  (* a_class = 17 *) class atr_c;
    rand int x;
    (* a_constraint = 18 *) constraint c1 { x > 0; }
  endclass
endmodule
