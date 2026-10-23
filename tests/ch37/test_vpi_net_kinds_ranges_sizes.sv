/*
:name: test_vpi_net_kinds_ranges_sizes
:description: Nets of each kind (logic, integer, time, struct, union, enum, packed array and array nets) give their type, vpiSize, vpiScalar and vpiVector, and the range iteration and leftmost bounds of packed and unpacked dimensions, with only the explicit ranges of packed array nets; a net bit is a scalar of size 1, and the type strings of logic and array nets are one of their two accepted names (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 6.7.1 7.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_kinds_ranges_sizes.c
:expected_stdout: @test_vpi_net_kinds_ranges_sizes.expected
*/
// IEEE 1800-2023 §37.16: logic, integer, time, struct, union, enum, packed
// array and array nets are members of the nets group. A net with an unpacked
// range is an array net; a packed struct, union or enum net with explicit
// packed ranges is a packed array net, whose range iteration gives only those
// explicit ranges, not the width of the struct or the range of the enum base
// (detail 1). vpiRange gives the unpacked ranges of an array net, and the
// packed ranges of a logic or packed array net, from the leftmost; vpiLeftRange
// and vpiRightRange of a logic or packed array net give the bounds of the
// leftmost packed range (detail 26). vpiSize is the number of nets of an array
// net, the number of bits of an integral net, 1 for a net bit and the number
// of members of an unpacked struct (detail 24). A logic net without packed
// range and a net bit are scalars; an enum net takes the flags of its base
// type; other integral nets are vectors; an array net takes the flags of its
// elements; other nets have neither (detail 28). The type string of an array
// net may be "vpiArrayNet" or "vpiNetArray" and that of a logic net "vpiNet"
// or "vpiLogicNet", which are the same constants (details 27, 29). Nets of
// these data types are legal (6.7.1, 7.4.1).

typedef struct packed { logic [1:0] f1; logic f2; } nkr_ps_t;
typedef union packed { logic [3:0] a; logic [3:0] b; } nkr_pu_t;
typedef enum logic [2:0] {E0, E1} nkr_en_t;
typedef enum logic {F0, F1} nkr_en1_t;

module test_vpi_net_kinds_ranges_sizes;
  wire s1;
  wire logic [3:0][1:0] lv;
  wire [3:0] w4;
  wire integer wi;
  wire time wt;
  wire nkr_ps_t psn;
  wire struct { logic a; logic b; } usn;
  wire nkr_pu_t pun;
  wire nkr_en_t enn;
  wire nkr_en1_t en1;
  wire nkr_ps_t [1:0] pan;
  wire nkr_en_t [4:3] pae;
  wire [7:0] an [0:2][5:4];
  wire sn [3:0];
  wire nkr_ps_t [1:0] apn [2:3];

  initial #1 $vt_nets;
endmodule
