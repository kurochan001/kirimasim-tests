/*
:name: test_vpi_net_members_elements_parents
:description: Struct and union nets iterate their member nets, whose parent is the nearest struct or union net and which are struct/union members with names prefixed in the full name and decompiled form; vpiElement walks a packed array net one dimension at a time down to struct nets, which are packed array members with the whole packed array net as parent and indices from right to left (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 38.21 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_members_elements_parents.c
:expected_stdout: @test_vpi_net_members_elements_parents.expected
*/
// IEEE 1800-2023 §37.16: vpiMember gives the member nets of a struct or union
// net. vpiParent of a net is, in prefix order from the right, the first struct
// or union net or struct or union member, else the largest packed array net,
// else the largest unpacked array net that contains it, and NULL without such a
// prefix (detail 31). vpiStructUnionMember is TRUE exactly for a net or array
// net whose parent is a struct or union net (detail 33). The full name and
// decompiled form of a member include the struct prefixes and its name does
// not; vpi_handle_by_name finds it by full name from the top and by decompiled
// form within the module (detail 34, 38.21). vpiElement of a packed array net
// gives its elements one dimension at a time, each the original type with the
// leftmost range removed, down to struct nets (detail 32); these have
// vpiPackedArrayMember TRUE (detail 2), the whole packed array net as parent,
// and vpi_iterate(vpiIndex) gives their indices from right to left as written
// (detail 25). The application sorts every list by name.

typedef struct packed { logic [1:0] p; logic q; } nmep_ps_t;

module test_vpi_net_members_elements_parents;
  wire struct {
    logic [2:0] k;
    logic [1:0] am [0:1];
    struct { logic m; logic n; } inner;
  } su;
  wire union packed { logic [1:0] x; logic [1:0] y; } pu;
  wire nmep_ps_t [2:0][1:0] pa;

  initial #1 $vt_members;
endmodule
