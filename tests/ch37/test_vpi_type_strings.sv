/*
:name: test_vpi_type_strings
:description: vpi_get_str(vpiType) gives the name of the type constant that vpi_get(vpiType) returns, for modules, nets, variables of each kind, arrays, bits, named events, parameters, named blocks, tasks and functions, and vpi_get_str(vpiNetType) the name of the net type (IEEE 1800-2023 Section 37.3.2)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.2 37.16 37.17 37.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_type_strings.c
:expected_stdout: @test_vpi_type_strings.expected
*/
// IEEE 1800-2023 §37.3.2: every object has vpiType; vpi_get gives the type
// constant, and vpi_get_str gives the name of that constant as a string. The
// additional type properties, such as vpiNetType, also give their constant's
// name through vpi_get_str. Some names have two accepted spellings: a logic
// net may be "vpiNet" or "vpiLogicNet" (37.16 detail 29), and a logic
// variable, its bit and an array of them "vpiReg" or "vpiLogicVar", "vpiRegBit"
// or "vpiVarBit", "vpiRegArray" or "vpiArrayVar" (37.17 detail 19). For each
// object the application prints the string, or both spellings when it is one
// of them, and whether the string names the constant from vpi_get.

module test_vpi_type_strings;
  parameter P = 3;
  wire [3:0] w;
  wand wa;
  tri1 t1;
  supply0 s0;
  logic [3:0] r;
  integer i;
  real re;
  time t;
  int ii;
  bit [3:0] bv;
  byte by;
  logic [3:0] mem [0:1];
  event ev;

  assign w = r;
  assign wa = r[0];
  assign wa = r[1];

  task tk;
    -> ev;
  endtask

  function int fn(int x);
    return x + 1;
  endfunction

  initial begin : blk
    r = 4'h3;
    i = fn(P);
    re = 0.5;
    t = 10;
    ii = 1;
    bv = 4'h5;
    by = 8'h7;
    mem[0] = r;
    tk;
    #1 $vt_types;
  end
endmodule
