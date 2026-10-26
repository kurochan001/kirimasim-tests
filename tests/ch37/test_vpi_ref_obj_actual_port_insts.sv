/*
:name: test_vpi_ref_obj_actual_port_insts
:description: A ref obj is the expression of a ref port of a variable, of an interface and of a modport port, and of a ref task argument; vpiActual gives the bound object of each, and vpiPortInst iterates the ports through which a local interface declaration is passed (IEEE 1800-2023 Section 37.15)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.15 37.13 37.14 23.2.2.3 25.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_ref_obj_actual_port_insts.c
:expected_stdout: @test_vpi_ref_obj_actual_port_insts.expected
*/
// IEEE 1800-2023 §37.15: a ref obj represents a declared object that is a
// reference to an actual instantiated object. The cases of detail 1 that this
// test declares are a variable that is the low connection of a ref port, an
// interface and a modport port, and a ref formal argument of a task.
// vpiActual gives the actual object each is bound to (detail 3), and
// vpiDefName gives the interface or modport definition name
// for an interface or modport actual (detail 6). vpi_iterate(vpiPortInst) over
// a ref obj gives the ports through which that local interface declaration is
// passed (37.15 diagram), here the two leaf instances of the child module.

interface trf_bus;
  logic req, gnt;
  modport dev (input req, output gnt);
endinterface

module trf_leaf (interface i);
endmodule

module trf_child (
  ref logic [3:0] r,
  trf_bus b,
  trf_bus.dev d
);
  trf_leaf c1 (b);
  trf_leaf c2 (b);
endmodule

module test_vpi_ref_obj_actual_port_insts;
  logic [3:0] v = 4'h6;
  trf_bus bi ();
  trf_child u (.r(v), .b(bi), .d(bi.dev));

  task t (ref logic [3:0] x);
    x = x + 1;
    $vt_taskref;
  endtask

  initial begin
    t(v);
    #1 $vt_refs;
  end
endmodule
