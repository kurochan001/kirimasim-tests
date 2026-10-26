/*
:name: test_vpi_io_direction_undefined
:description: The io declaration of an interface port, a modport port and a virtual interface task formal gives vpiDirection vpiUndefined, while a ref port gives vpiRef (IEEE 1800-2023 Section 37.13)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.13 25.5 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_io_direction_undefined.c
:expected_stdout: @test_vpi_io_direction_undefined.expected
*/
// IEEE 1800-2023 §37.13: vpiDirection returns vpiRef for a port or argument
// passed by reference (detail 1). It shall be undefined when the vpiExpr of
// the io declaration is a ref obj whose vpiActual is an interface or modport
// declaration, and also when the vpiExpr is a virtual interface variable
// (detail 3). Undefined is vpiUndefined, which vpi_get returns as -1
// (Annex K); vpiRef is 6. Each module and the task declare one such io
// declaration, whose vpiExpr is a ref obj for the interface, modport and ref
// ports (detail 2) and a virtual interface variable for the task formal.

`timescale 1ns/1ns

interface iod_bus;
  logic v;
  modport mp(input v);
endinterface

module iod_ifc(iod_bus s);
endmodule

module iod_mp(iod_bus.mp m);
endmodule

module iod_ref(ref logic r);
endmodule

module test_vpi_io_direction_undefined;
  iod_bus b();
  logic r = 0;

  iod_ifc u1(b);
  iod_mp u2(b);
  iod_ref u3(r);

  task automatic vt(virtual iod_bus v);
    #1 $vt_dir;
  endtask

  initial vt(b);
endmodule
