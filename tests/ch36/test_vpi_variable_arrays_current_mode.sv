/*
:name: test_vpi_variable_arrays_current_mode
:description: without a compatibility mode, an unpacked array of reg, integer, time or real variables is a vpiRegArray (vpiArrayVar) whose elements vpiReg iterates with their own types, vpiMemory and vpiMemoryWord return vpiRegArray and vpiReg objects, vpiVariables includes reg and array variables, vpiRegArray includes every variable array, and vpiReg and vpiRegArray equal vpiLogicVar and vpiArrayVar (IEEE 1800-2023 Section 36.12.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1 37.17 37.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_arrays_current_mode.c
:expected_stdout: @test_vpi_variable_arrays_current_mode.expected
*/
// IEEE 1800-2023 §36.12.1 (Table 36-10, column 1800-2012/2017/2023, and its
// details): vpiReg and vpiRegArray are the same types as vpiLogicVar and
// vpiArrayVar (37.17 detail 19). In this version
// 1) and 2) vpiMemory and vpiMemoryWord are no object types: they are a
//    relation that returns reg arrays as vpiRegArray objects and an iteration
//    that returns their words as vpiReg objects (37.20 detail 1);
// 3) and 4) an integer, time or real variable is never an array: unpacked
//    arrays of them are vpiRegArray objects, while the plain variables keep
//    the types vpiIntegerVar, vpiTimeVar and vpiRealVar;
// 5) vpiVariables of a scope includes vpiReg and vpiRegArray objects;
// 6) vpiReg over a vpiRegArray returns its elements, which can be integer,
//    time or real variables;
// 7) vpiRegArray of a scope includes the arrays of integer, time and real
//    variables.
// The VPI application defines no VPI_COMPATIBILITY_VERSION_ macro, so it gets
// this behavior. At the start of simulation it prints the types it finds,
// with its own names for the type constants (vpiReg for vpiLogicVar,
// vpiRegArray for vpiArrayVar), since vpi_get_str(vpiType) may give either
// name (37.17 detail 19). Lists of names are sorted. vpiMemory may also
// return the other variable arrays, so only mem and the types are printed.
// Icarus Verilog 13.0 gives the arrays the type vpiMemory and their elements
// vpiMemoryWord, gives the time variable the type vpiReg, leaves arrays and
// logic and time variables out of vpiVariables and returns NULL for
// vpiRegArray. Under Verilator 5.052 the integer and time variables and the
// elements of their arrays have the type vpiReg, and vpiMemory,
// vpiMemoryWord, vpiVariables and vpiRegArray return NULL.

module test_vpi_variable_arrays_current_mode;
  reg [7:0] mem [0:3];
  integer ia [0:1];
  time ta [0:1];
  real ra [0:1];
  logic [3:0] lv;
  integer iv;
  time tv;
  real rv;

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
