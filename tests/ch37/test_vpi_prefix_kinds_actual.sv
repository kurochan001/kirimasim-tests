/*
:name: test_vpi_prefix_kinds_actual
:description: Part-selects, indexed part-selects, named events and task calls prefixed by a virtual interface, a clocking block or a class variable lead to that prefix with vpiPrefix, an unprefixed one to NULL; vpiHasActual follows whether the prefix has an actual at the current time, is TRUE for a static object and FALSE for a non-static class property taken from the class typespec (IEEE 1800-2023 Section 37.61)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.61 37.32 25.9 14.3 8.4 38.36.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_prefix_kinds_actual.c
:expected_stdout: @test_vpi_prefix_kinds_actual.expected
*/
// IEEE 1800-2023 §37.61: indexed part-selects, part-selects, named events and
// task calls lead with vpiPrefix to a class variable, virtual interface
// variable or clocking block; the relation is non-NULL when the source
// expression or call is prefixed by a virtual interface or a clocking block,
// or is part of a non-static class property prefixed by a class variable
// (detail 1). vpiHasActual is TRUE when the prefix has an actual at the
// current time, or the object is part of a static object in an elaborated
// context; it is FALSE when the prefix has none, or the object is a non-static
// class property obtained from its class typespec (detail 3; 37.32).
//
// The task peek, never called, reads vi.data and obj.f through a virtual
// interface (25.9) and a class variable (8.4), both null until time 1,
// triggers vi.ev, calls vi.ping, reads cb.d through a clocking block (14.3)
// and selects bits of the module variable local_v. The application registers
// a cbAtStartOfSimTime callback at 1, before vi and obj are set, and a
// cbReadOnlySynch callback at 1, after (38.36.2). Each prints, for every
// object, its prefix (name and kind, or NULL) and vpiHasActual, and
// vpiHasActual of the property f taken from the class typespec of obj; the
// lines are sorted.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiPrefix and vpiHasActual, and a run
// with Verilator 5.052 gives no statements of the task.

`timescale 1ns/1ns

interface dpk_bus;
  logic [7:0] data;
  event ev;
  task ping;
  endtask
endinterface

module test_vpi_prefix_kinds_actual;
  class holder;
    logic [7:0] f;
  endclass

  logic clk;
  logic [7:0] local_v, d;
  logic [3:0] r1, r2, r3, r4, r5;
  dpk_bus b1 ();
  virtual dpk_bus vi;
  holder obj;

  clocking cb @(posedge clk);
    input d;
  endclocking

  task peek;
    r1 = vi.data[3:0];
    r2 = vi.data[4+:4];
    -> vi.ev;
    vi.ping();
    r3 = cb.d[7:4];
    r4 = obj.f[2+:4];
    r5 = local_v[3:0];
  endtask

  initial begin
    #1;
    vi = b1;
    obj = new();
  end
endmodule
