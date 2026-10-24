/*
:name: test_vpi_struct_union_flags_members
:description: Struct and union variables and their typespecs give vpiTagged, vpiSoft and vpiPacked according to the declaration (tagged union, soft packed union, hard packed union, packed and unpacked struct); struct and union typespecs iterate their typespec members, named by the member identifier, each with the typespec of its declared type (a void typespec for a void member of a tagged union) and with vpiRandType from its random qualifier (IEEE 1800-2023 Sections 37.25 and 37.26)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.25 37.26 7.2 7.2.1 7.3 7.3.1 7.3.2 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_struct_union_flags_members.c
:expected_stdout: @test_vpi_struct_union_flags_members.expected
*/
// IEEE 1800-2023 §37.26 and §37.25: struct and union variables and struct and
// union typespecs have the Boolean properties vpiTagged, vpiSoft and vpiPacked.
// A struct is never tagged or soft; sp_t is packed and su_t is not (7.2.1).
// The union upk_t is hard packed, us_t soft packed (the soft qualifier makes
// it packed without the packed keyword, 7.3.1) and ut_t tagged and unpacked
// (7.3.2). §37.25 details 3 and 4: a struct or union typespec iterates
// vpiTypespecMember; vpiName of a member is the member identifier, not the
// name of its type (sub, not sp_t), and the typespec of a member is the type it
// was declared with; the void member none of ut_t has a void typespec. A
// typespec member has vpiRandType: ra is rand, rc randc and the others not
// random (members of an unpacked struct may be declared rand or randc, 7.2,
// 18.4). Members are listed sorted by name.

module test_vpi_struct_union_flags_members;
  typedef struct packed { logic [3:0] hi; bit [3:0] lo; } sp_t;
  typedef struct { rand int ra; randc bit [1:0] rc; int pl; sp_t sub; } su_t;
  typedef union packed { logic [7:0] w; sp_t s; } upk_t;
  typedef union tagged { void none; int val; } ut_t;
  typedef union soft { logic [7:0] a; logic [3:0] b; } us_t;

  sp_t vsp;
  su_t vsu;
  upk_t vup;
  ut_t vut;
  us_t vus;

  initial #1 $vt_flags;
endmodule
