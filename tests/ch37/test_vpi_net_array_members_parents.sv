/*
:name: test_vpi_net_array_members_parents
:description: An unpacked array net, its elements and the members of an unpacked struct net report vpiSize, vpiArrayMember, vpiPackedArrayMember and vpiStructUnionMember, packed struct, union and enum array nets and their elements and a nested packed array net are classified, their parent net follows the prefix rules, a net bit has size 1, packed array nets iterate only their explicit ranges, and the Boolean properties vpiArray and vpiExpanded are readable (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 7.4.1 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_array_members_parents.c
:expected_stdout: @test_vpi_net_array_members_parents.expected
*/
// IEEE 1800-2023 §37.16: a net with an unpacked range is an array net
// (detail 1). Its vpiSize is the number of nets, an integral net's vpiSize is
// its number of bits, a net bit's is 1 and an unpacked struct or union net's
// is its number of members (detail 24). vpiArrayMember is TRUE for an element
// of an array net and FALSE otherwise; vpiPackedArrayMember is TRUE for a
// packed struct, union, enum or array net that is an element of a packed
// array net (detail 2); vpiStructUnionMember is TRUE for a direct member of a
// struct or union net (detail 33). vpiParent gives the nearest prefix that is
// a struct or union net, a struct or union member, the largest containing
// packed array net or the largest containing unpacked array net, or NULL
// (detail 31). The printed parent name is its vpiName, which keeps the indices
// of an element but drops the struct prefix of a member, so the parent of
// bv[6] is named bv while the handle is still sa[4][1].bv (detail 34). The
// member id is declared integer, so it is an integer net, a net kind apart
// from an int net (the diagram; vpiIntegerNet in Annex M). A packed array net
// iterates only its explicit packed ranges (detail 1), and vpiArray and
// vpiExpanded are Boolean (details 2, 21); whether a vector is expanded is
// left to the tool, so only that the value is 0 or 1 is printed. A logic
// net's bits exist whether or not it is expanded (detail 3). Nets of these
// types are legal (7.4.1, 6.7.1).

typedef struct packed { logic hi; logic lo; } nap_pair_t;
typedef enum logic [1:0] {NAP_A, NAP_B, NAP_C} nap_enum_t;
typedef union packed { logic [1:0] ulo; logic [1:0] uhi; } nap_union_t;

module test_vpi_net_array_members_parents;
  wire logic [1:0][3:2] vv4 [7:5][9:8];
  wire struct { integer id; logic [2:1][3:2] bv [6:5]; } sa [4:2][1:0];
  wire nap_pair_t [1:0] psa;
  wire nap_enum_t [4:3] pea;
  wire nap_union_t [3:2] pua;
  wire nap_pair_t [1:0][3:0] ppa;
  wire union { integer ui; logic [3:0] ub; } un;
  wire vectored [3:0] vv;
  wire scalared [3:0] ss;

  initial #1 $vt_nets;
endmodule
