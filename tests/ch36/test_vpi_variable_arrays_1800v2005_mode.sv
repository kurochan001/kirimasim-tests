/*
:name: test_vpi_variable_arrays_1800v2005_mode
:description: in the VPI compatibility mode 1800v2005, arrays of reg, integer, time and real variables are vpiRegArray objects with elements of their own types, vpiMemory and vpiMemoryWord return vpiRegArray and vpiReg objects, vpiVariables includes reg and array variables, vpiRegArray includes every variable array, and vpiInterfaceDecl of a class definition returns vpiRefObj objects (IEEE 1800-2023 Section 36.12.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1 36.12.2.1 L.2 37.17 37.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_arrays_1800v2005_mode.c
:expected_stdout: @test_vpi_variable_arrays_1800v2005_mode.expected
*/
// IEEE 1800-2023 §36.12.1: Table 36-10 gives, for each version, which of nine
// VPI behaviors it has. In the column of IEEE Std 1800-2005
// 1) and 2) vpiMemory and vpiMemoryWord are no object types: they return reg
//    arrays as vpiRegArray objects and their words as vpiReg objects;
// 3) and 4) arrays of integer, time and real variables are vpiRegArray
//    objects, and vpiIntegerVar, vpiTimeVar and vpiRealVar are plain
//    variables;
// 5) vpiVariables of a scope includes vpiReg and vpiRegArray objects;
// 6) vpiReg over a vpiRegArray returns its elements of other types too;
// 7) vpiRegArray of a scope includes the arrays of integer, time and real;
// 8) and 9) vpiInterfaceDecl can be iterated on a vpiClassDefn, and gives
//    vpiRefObj objects.
// vpiReg and vpiRegArray are the types vpiLogicVar and vpiArrayVar.
// §36.12.2.1: an application that defines VPI_COMPATIBILITY_VERSION_1800v2005
// as 1 before it includes the VPI headers gets this behavior, since
// vpi_user.h then makes vpi_iterate, vpi_scan, vpi_get, vpi_get_str,
// vpi_handle_by_name and vpi_register_cb the routines of that mode (L.2).
// The VPI application of this test does so. At the start of simulation it
// prints the types it finds, with its own names for the type constants, as
// the test without a mode does; lists of names are sorted. The class holder
// of the module va05_classes has one virtual interface variable.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 provides the routines of
// the compatibility modes: Icarus Verilog rejects the virtual interface
// member of the class and its headers lack vpiInterfaceDecl, vpiRefObj and
// vpiVirtualInterfaceVar, and the vpi_user.h of Verilator does not remap the
// routines, so the application gets the behavior of that release.

interface va05_if;
  logic s;
endinterface

module va05_classes;
  va05_if i0();

  class holder;
    virtual va05_if vif;
  endclass

  holder h;

  initial begin
    h = new;
    h.vif = i0;
  end
endmodule

module test_vpi_variable_arrays_1800v2005_mode;
  reg [7:0] mem [0:3];
  integer ia [0:1];
  time ta [0:1];
  real ra [0:1];
  logic [3:0] lv;
  integer iv;
  time tv;
  real rv;

  va05_classes u_cls();

  initial begin
    mem[0] = 8'd1;
    ia[0] = 2;
    ta[0] = 3;
    ra[0] = 4.0;
    lv = 4'd5;
    iv = 6;
    tv = 7;
    rv = 8.0;
    #1 $display("design: %0d %0d %0d %0.1f %0d %0d %0d %0.1f",
                mem[0], ia[0], ta[0], ra[0], lv, iv, tv, rv);
  end
endmodule
