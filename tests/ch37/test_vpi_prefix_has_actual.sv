/*
:name: test_vpi_prefix_has_actual
:description: An expression prefixed by a virtual interface or a class variable gives the prefix through vpiPrefix, and vpiHasActual tells whether the prefix refers to an actual object at that time (IEEE 1800-2023 Section 37.61)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.61 37.29 37.33
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_prefix_has_actual.c
:expected_stdout: @test_vpi_prefix_has_actual.expected
*/
// IEEE 1800-2023 §37.61: vpiPrefix is non-NULL for an expression prefixed by a
// virtual interface or a clocking block, or for a property of a class object
// reached through a class variable, and vpiHasActual is TRUE when the prefix
// has an actual at the current time and FALSE when it has none. The right-hand
// sides of the two assignments in the task peek, which is never called, are
// vi.sig and c.v. At 1, vi and c are null; at 2 they refer to b1 and to an
// object.

`timescale 1ns/1ns

interface test_vpi_prefix_has_actual_bus;
  logic sig;
endinterface

module test_vpi_prefix_has_actual;
  class box;
    int v;
  endclass

  test_vpi_prefix_has_actual_bus b1();
  virtual test_vpi_prefix_has_actual_bus vi;
  box c;
  logic r;
  int q;

  task peek;
    begin
      r = vi.sig;
      q = c.v;
    end
  endtask

  initial begin
    #1 $vt_prefix;
    vi = b1;
    c = new();
    #1 $vt_prefix;
  end
endmodule
