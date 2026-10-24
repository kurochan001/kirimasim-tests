/*
:name: test_vpi_struct_union_net_flags
:description: Struct and union nets iterate their member nets with vpiMember, each member net has the struct or union net as vpiParent, and vpiTagged, vpiSoft and vpiPacked of the nets follow their declarations (packed and unpacked struct, hard packed, soft packed and unpacked union) (IEEE 1800-2023 Section 37.26)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.26 37.16 6.7.1 7.2.1 7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_struct_union_net_flags.c
:expected_stdout: @test_vpi_struct_union_net_flags.expected
*/
// IEEE 1800-2023 §37.26: a struct net or union net (a net of a struct or union
// type, 6.7.1) iterates its member nets with vpiMember, and each member net
// leads back to it with vpiParent; struct and union nets have vpiTagged,
// vpiSoft and vpiPacked. A struct is never tagged or soft, snp is packed and
// snu unpacked (7.2.1). The union nets are untagged; unp is hard packed, uns
// soft packed (packed through the soft qualifier, 7.3.1) and unu unpacked
// (an unpacked union of 4-state members is a valid net type, 6.7.1). Members
// are listed sorted by name.

module test_vpi_struct_union_net_flags;
  typedef struct packed { logic [1:0] a; logic b; } nsp_t;
  typedef struct { logic x; logic [2:0] y; } nsu_t;
  typedef union packed { logic [2:0] w; nsp_t s; } nup_t;
  typedef union soft { logic [2:0] p; logic q; } nus_t;
  typedef union { logic [1:0] m; logic n; } nuu_t;

  wire nsp_t snp;
  wire nsu_t snu;
  wire nup_t unp;
  wire nus_t uns;
  wire nuu_t unu;

  initial #1 $vt_nets;
endmodule
