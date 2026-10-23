/*
:name: test_vpi_user_defined_net_kinds
:description: Nets declared with user-defined nettypes of each data type are the shortreal, real, byte, shortint, int, longint, integer, time, bit, logic, packed array, struct, union and enum net objects, all with vpiNetType vpiNettypeNet, the size of their data type, and the packed ranges of bit, logic and packed array nets (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_user_defined_net_kinds.c
:expected_stdout: @test_vpi_user_defined_net_kinds.expected
*/
// IEEE 1800-2023 §37.16: a user-defined net is a member of the net group, and
// the user-defined net group holds short real, real, byte, short int, int, long
// int, integer, time, packed array, bit, logic, struct, union and enum nets
// (vpiShortRealNet ... vpiEnumNet in Annex M). A net declared with a nettype
// has vpiNetType vpiNettypeNet (detail 11). vpiSize of a net of an integral
// data type is its number of bits (detail 24); bit, logic and packed array
// nets have vpiRange, vpiLeftRange and vpiRightRange, which give the packed
// ranges from the leftmost (detail 26). Each net below is declared with a
// nettype of one data type that 6.6.7 allows; none has a driver. The size is
// printed only for integral nets.

typedef struct packed { logic [1:0] a; logic b; } udnk_ps_t;
typedef union packed { logic [2:0] x; logic [2:0] y; } udnk_pu_t;
typedef enum logic [1:0] {UDNK0, UDNK1} udnk_en_t;

nettype shortreal udnk_sr_nt;
nettype real udnk_r_nt;
nettype byte udnk_b_nt;
nettype shortint udnk_si_nt;
nettype int udnk_i_nt;
nettype longint udnk_li_nt;
nettype integer udnk_ig_nt;
nettype time udnk_t_nt;
nettype bit [5:2] udnk_bit_nt;
nettype logic [3:1] udnk_l_nt;
nettype udnk_ps_t [1:0] udnk_pa_nt;
nettype udnk_ps_t udnk_s_nt;
nettype udnk_pu_t udnk_u_nt;
nettype udnk_en_t udnk_e_nt;

module test_vpi_user_defined_net_kinds;
  udnk_sr_nt nsr;
  udnk_r_nt nr;
  udnk_b_nt nb;
  udnk_si_nt nsi;
  udnk_i_nt ni;
  udnk_li_nt nli;
  udnk_ig_nt nig;
  udnk_t_nt nt;
  udnk_bit_nt nbit;
  udnk_l_nt nl;
  udnk_pa_nt npa;
  udnk_s_nt ns;
  udnk_u_nt nu;
  udnk_e_nt ne;

  initial #1 $vt_udn;
endmodule
