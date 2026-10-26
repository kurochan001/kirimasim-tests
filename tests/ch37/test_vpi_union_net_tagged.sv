/*
:name: test_vpi_union_net_tagged
:description: vpiTagged of a union net is TRUE for a tagged union and FALSE for an untagged union and for a struct net, and a tagged union net still iterates its member nets (IEEE 1800-2023 Section 37.26)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.26 7.3 7.3.2 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_union_net_tagged.c
:expected_stdout: @test_vpi_union_net_tagged.expected
*/
// IEEE 1800-2023 §37.26: struct and union nets expose vpiTagged, which is
// TRUE for a union declared with the tagged qualifier and FALSE for any other
// struct or union (§7.3, §7.3.2). A net may have a struct or union type
// (§6.7.1), so the test declares a tagged union net, an untagged union net
// and a struct net and prints vpiTagged and vpiPacked for each, together with
// the member nets returned by vpiMember, which a tagged union keeps.

module test_vpi_union_net_tagged;
  typedef union tagged { logic [7:0] a; logic [7:0] b; } tagged_u;
  typedef union { logic [7:0] a; logic [7:0] b; } plain_u;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } pair_s;

  wire tagged_u tn;
  wire plain_u pn;
  wire pair_s sn;

  initial #1 $vt_tagged;
endmodule
