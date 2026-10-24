/*
:name: test_vpi_variable_parent_prefixes
:description: vpiParent of a variable is the nearest prefix that is a struct, union or class variable, a struct or union member, the largest containing packed array or the largest containing unpacked array, else NULL; member variables are named without and fully named and decompiled with their prefixes and indices and found by either form; a non-static member referenced through a class var has no full name and that class var as parent, a static one the full name through the class, and members reached from the class object have no parent; vpiConstantSelect follows lifetime, prefixes and indices (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.26 37.33 37.61 38.21 7.2 7.3 8.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_parent_prefixes.c
:expected_stdout: @test_vpi_variable_parent_prefixes.expected
*/
// IEEE 1800-2023 §37.17 detail 26: the prefixes of a variable are the names
// left after removing, one at a time from the right, an index or member name.
// vpiParent is the first of them that is a struct, union or class variable, a
// struct or union member, the largest containing packed array or the largest
// containing unpacked array; with no such prefix it is NULL. So ra[1] (a
// struct element) has ra, its members k, w and in have ra[1], the element
// w[0] of the member array w has w (a struct member), in.c has in, the members
// raw and hl of the packed union un have un (37.26) and hl.h has hl, mv[2] has
// mv, the bits of mv[2] have mv[2] (the largest packed array containing them),
// and solo, ra, un and mv have none. A class var is a parent only when the
// design references the member through it (detail 26): obj.m, an argument of
// $vt_parents, has obj, while m reached from the class object of obj (37.33)
// or from the class defn has NULL. Detail 28: vpiName of a member has no
// prefixes, vpiFullName and vpiDecompile have all of them, and all three keep
// the indices of elements; vpi_handle_by_name (38.21) finds a member by its
// full name from the top and by its decompiled name within the module.
// Detail 25: the non-static obj.m has no vpiFullName, the static sm, through
// obj or through the class, has the full name through the class. Detail 27:
// vpiConstantSelect is TRUE for the static solo and obj, which have no
// parent, and for selects with constant indices of members and elements of
// arrays with static bounds (ra[1].in.c, un.hl.h, ra[1].k, the bits of mv[2]);
// FALSE for ra[k].k, whose index is a variable, for the element da[0] and the
// member rd[0].k of dynamic arrays, and for obj.m, an automatic member of a
// class var.

module test_vpi_variable_parent_prefixes;
  typedef struct packed { logic [3:0] h, l; } hl_t;
  typedef struct {
    int k;
    logic [3:0] w [0:1];
    struct { byte c; } in;
  } rec_t;
  class pc;
    int m;
    static int sm;
  endclass

  rec_t ra [0:1];
  rec_t rd [];
  union packed { logic [7:0] raw; hl_t hl; } un;
  logic [2:0][3:0] mv [1:2];
  int da [];
  int solo;
  int k = 1;
  pc obj = new;

  initial begin
    rd = new[1];
    da = new[1];
    obj.m = 5;
    pc::sm = 6;
    ra[1].k = 7;
    #1 $vt_parents(obj.m, obj.sm, pc::sm, ra[k].k, ra[1].k);
  end
endmodule
