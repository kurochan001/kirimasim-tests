/*
:name: test_vpi_variable_kinds_flags_sizes
:description: Shortreal, enum, string, chandle, class and virtual interface variables are variables with their own vpiType and the group's name, scope and flag properties; vpiScalar and vpiVector follow the kind of a variable (enums their base type, arrays their elements), vpiSize is the bit width of integral, enum and packed struct and union variables, 1 for a var bit, the field count of an unpacked struct or union and the current length of a string; unpacked dimensions make an array var whose elements are array members; logic variables, their bits and arrays of them may be named with the reg names (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 6.11 6.12 6.14 6.16 6.19 7.2 7.3 8.4 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_kinds_flags_sizes.c
:expected_stdout: @test_vpi_variable_kinds_flags_sizes.expected
*/
// IEEE 1800-2023 §37.17: shortreal, enum, string, chandle, class and virtual
// interface variables belong to the variables group, so they have the group's
// vpiName, vpiFullName and vpiScope (here the module). vpiScalar and vpiVector
// (detail 20): a bit or logic variable without packed dimension and a var bit
// are scalars; one with packed dimensions, a packed struct or union and the
// integer, time, shortint, int, longint and byte variables are vectors; an
// enum variable takes the flags of its base type (logic [2:0]: vector; bit:
// scalar; int: vector); an array var those of its elements (logic: scalar;
// logic [3:0]: vector; real: neither); every other kind has both FALSE.
// vpiSize (detail 9): the width in bits for integral, enum and packed struct
// and union variables, 1 for a var bit, the number of fields of an unpacked
// struct (3) or union (2), the number of elements of an array var, and for a
// string var its current number of characters: 3 at 1, 6 at 2 after the
// design assigns "length". Detail 1 and 2: a variable with an unpacked
// dimension is an array var, one with only packed dimensions is not, and
// vpiArrayMember is TRUE exactly for elements of an array. Detail 19:
// vpiLogicVar, vpiVarBit and vpiArrayVar equal vpiReg, vpiRegBit and
// vpiRegArray, vpi_get_str(vpiType) may give either name, and a var bit can be
// a bit of a 2-state bit variable.

interface test_vpi_variable_kinds_flags_sizes_if;
  logic x;
endinterface

module test_vpi_variable_kinds_flags_sizes;
  typedef enum logic [2:0] {K0, K1, K2} e3_t;
  typedef enum bit {OFF, ON} e1_t;
  typedef enum {I0, I1} ei_t;
  typedef struct packed { logic [3:0] a; bit [3:0] b; } ps_t;
  typedef union packed { logic [7:0] w; ps_t s; } pu_t;
  typedef struct { int f1; byte f2; logic f3; } us_t;
  typedef union { int g1; shortint g2; } uu_t;
  class cls;
    int m;
  endclass

  test_vpi_variable_kinds_flags_sizes_if bus();

  shortreal sr = 2.5;
  e3_t e3 = K2;
  e1_t e1 = ON;
  ei_t ei = I1;
  string s = "abc";
  chandle ch;
  cls c = new;
  virtual test_vpi_variable_kinds_flags_sizes_if vi = bus;
  logic l1;
  bit b1;
  logic [4:0] l5;
  bit [1:0][2:0] b6;
  integer ig;
  time tm;
  shortint sh;
  int i32;
  longint lg;
  byte by;
  real re;
  ps_t ps;
  pu_t pu;
  us_t us;
  uu_t uu;
  logic as1 [0:1];
  logic [3:0] av4 [0:2];
  real ar [0:1];
  int m2d [0:1][0:2];

  initial begin
    #1 $vt_kinds;
    s = "length";
    #1 $vt_string;
  end
endmodule
