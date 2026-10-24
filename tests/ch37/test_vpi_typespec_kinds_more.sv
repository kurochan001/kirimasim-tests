/*
:name: test_vpi_typespec_kinds_more
:description: The typespecs of shortreal, real, byte, shortint, longint, integer, class, string, union, bit, packed array, event and virtual interface variables, of sequence and property formals and of a class property declared with an unresolved type parameter are typespecs of their own kinds with the group's name property; an enum typespec leads to its base type and an enum constant to its enum typespec; a typespec leads to its instance; vpiIndexTypespec gives the key type of an associative array type, NULL for a wildcard key and for other arrays (IEEE 1800-2023 Sections 37.25 and 37.29)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.25 37.29 37.30 37.31 37.51 37.53 6.19 7.8 8.25 16.8.1 16.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_typespec_kinds_more.c
:expected_stdout: @test_vpi_typespec_kinds_more.expected
*/
// IEEE 1800-2023 §37.25: the typespec group has a member for each kind of type;
// vpi_handle(vpiTypespec, var) gives the typespec of a variable, whose vpiName
// is its typedef name, or NULL for a built-in type (detail 1; the name of a
// class typespec is left to 37.32 and not printed). The variables here give a
// shortreal, real, byte, shortint (built-in and through the typedef sh_t),
// longint, integer, class, string, union, bit, packed array (of a packed
// struct), event and interface typespec (for a virtual interface var, 37.29,
// whose vpiDefName is the interface, 37.30). A formal of a sequence or
// property declaration declared with the type sequence or property has a
// sequence or a property typespec (37.53, 37.51; 16.8.1, 16.12.1). In the
// class defn tp_c (37.31) the type parameter T is not resolved, so the
// typespec of its property mem is the type parameter T itself (detail 11).
// vpiBaseTypespec of the enum typespec of ve is the byte typespec of its base
// type, and each enum constant leads with vpiEnumTypespec to that enum
// typespec. vpiInstance of the typespec of the typedef sh_t is the module.
// vpiIndexTypespec (detail 2) of the type of aa_s is the string typespec, of
// aa_i an int typespec, of the wildcard aa_w NULL, and of the static array sa
// NULL, the relation being present only for associative array typespecs.

interface test_vpi_typespec_kinds_more_if;
  logic x;
endinterface

module test_vpi_typespec_kinds_more;
  typedef shortint sh_t;
  typedef enum byte {VB0 = 1, VB1 = 5} be_t;
  typedef struct packed { logic [1:0] p; } p2_t;
  class tc;
    int v;
  endclass
  class tp_c #(type T = int);
    T mem;
  endclass

  test_vpi_typespec_kinds_more_if bus();

  shortreal v_sr;
  real v_re;
  byte v_by;
  shortint v_sh;
  sh_t v_sht;
  longint v_lg;
  integer v_ig;
  tc v_cl;
  string v_st;
  union packed { logic [3:0] a; bit [3:0] b; } v_un;
  bit v_bt;
  p2_t [2:0] v_pa;
  event v_ev;
  virtual test_vpi_typespec_kinds_more_if v_vi;
  be_t ve;
  int aa_s [string];
  int aa_i [int];
  int aa_w [*];
  int sa [3];

  sequence s_twice(sequence a);
    a ##1 a;
  endsequence

  property p_then(sequence a, property b);
    a |-> b;
  endproperty

  initial #1 $vt_typespecs;
endmodule
