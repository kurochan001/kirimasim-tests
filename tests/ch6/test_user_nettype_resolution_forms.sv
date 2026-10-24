/*
:name: test_user_nettype_resolution_forms
:description: User-defined nettypes of 4-state, 2-state, real, shortreal and unpacked data types, with resolvers named directly, through a package scope or as static methods of a parameterized class, renamed through a package scope, declared with a delay, as arrays and without a resolver, resolve their nets as a whole (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.7 6.6 6.7 6.7.2 6.7.3 13.8
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_user_nettype_resolution_forms.expected
*/
// IEEE 1800-2023 §6.6.7: a nettype gives a data type, which it requires, and
// optionally a resolution function, named directly or with a package or class
// scope; a second form gives another name to an existing nettype, optionally
// through a package scope. Valid data types are 4-state and 2-state integral
// types (packed aggregates included), real and shortreal, and fixed-size
// unpacked arrays and structures of valid types. A resolver takes a dynamic
// array of the driver values, is automatic and keeps no state, and is called
// when a driver changes; it can be a static method of a parameterized class
// (13.8). Two nettypes can share a data type with different resolvers. A net
// of a user-defined nettype is resolved as a whole, while a logic vector net
// resolves each bit on its own (6.6). §6.7: the declaration of such nets can
// have a delay and a list of nets; §6.7.2: each net, also in an array, uses
// the data type and resolver of its nettype. §6.7.3: an undriven net of a
// nettype without a resolver starts with the default of its type, x for logic.
// add4 adds its drivers modulo 16: 3 + 5 is 4'b1000, where the wire w_vec
// gives 0xx1. The other resolvers OR, add or take the largest value. a goes to
// 1 at 10 and back to 3 at 20; s_del has a delay of 3.
// Oracle checks: neither Icarus Verilog 13.0 nor the 5.052 release supports
// user-defined nettypes, so the expected output follows the cited clauses
// alone.

package test_user_nettype_resolution_forms_pkg;
  function automatic logic [3:0] add4(input logic [3:0] d[]);
    add4 = 4'd0;
    foreach (d[i]) add4 += d[i];
  endfunction
  nettype logic [3:0] add_net with add4;
endpackage

class test_user_nettype_resolution_forms_cls #(type T = int);
  static function T max_of(input T d[]);
    max_of = 0;
    foreach (d[i]) if (i == 0 || d[i] > max_of) max_of = d[i];
  endfunction
endclass

module test_user_nettype_resolution_forms;
  import test_user_nettype_resolution_forms_pkg::*;

  typedef struct packed { bit [1:0] hi; bit [1:0] lo; } pk2_t;
  typedef struct { real v; logic [1:0] tag; } us_t;
  typedef shortreal sr_arr_t [2];

  function automatic pk2_t or2(input pk2_t d[]);
    or2 = '0;
    foreach (d[i]) or2 |= d[i];
  endfunction

  function automatic us_t mix(input us_t d[]);
    mix = '{0.0, 2'b00};
    foreach (d[i]) begin
      mix.v += d[i].v;
      mix.tag |= d[i].tag;
    end
  endfunction

  function automatic sr_arr_t add_sr(input sr_arr_t d[]);
    add_sr = '{0.0, 0.0};
    foreach (d[i]) begin
      add_sr[0] += d[i][0];
      add_sr[1] += d[i][1];
    end
  endfunction

  nettype pk2_t or_net with or2;
  nettype us_t mix_net with mix;
  nettype sr_arr_t sr_net with add_sr;
  nettype real rmax_net with test_user_nettype_resolution_forms_cls#(real)::max_of;
  nettype int imax_net with test_user_nettype_resolution_forms_cls#(int)::max_of;
  nettype logic [3:0] pkg_add_net with test_user_nettype_resolution_forms_pkg::add4;
  nettype test_user_nettype_resolution_forms_pkg::add_net add_alias;
  nettype logic [3:0] plain_nib;
  nettype shortreal plain_sr;

  logic [3:0] a = 4'd3, b = 4'd5;

  add_net s_add;
  wire [3:0] w_vec;
  add_alias s_alias;
  pkg_add_net s_pkg;
  or_net s_or;
  mix_net s_mix;
  sr_net s_sr;
  rmax_net s_rmax;
  imax_net s_imax;
  plain_sr s_plain;
  plain_nib s_undriven;
  wire [3:0] w_undriven;
  add_net arr [0:1];
  plain_nib parr [0:1];
  add_net #3 s_del, s_del2;

  assign s_add = a;
  assign s_add = b;
  assign w_vec = a;
  assign w_vec = b;
  assign s_alias = a;
  assign s_alias = b;
  assign s_pkg = a;
  assign s_pkg = b;
  assign s_or = 4'b1000;
  assign s_or = 4'b0010;
  assign s_mix = '{1.5, 2'b01};
  assign s_mix = '{2.0, 2'b10};
  assign s_sr = '{0.5, 1.0};
  assign s_sr = '{0.25, 2.0};
  assign s_rmax = 1.5;
  assign s_rmax = -2.0;
  assign s_imax = -7;
  assign s_imax = -3;
  assign s_plain = 0.5;
  assign arr[0] = a;
  assign arr[0] = b;
  assign arr[1] = a;
  assign arr[1] = a;
  assign parr[0] = a;
  assign parr[1] = b;
  assign s_del = a;
  assign s_del2 = b;

  initial begin
    #1 $display("add: s_add=%b wire=%b alias=%b pkg=%b", s_add, w_vec, s_alias, s_pkg);
    $display("2-state or=%b unpacked struct v=%0.2f tag=%b shortreal array %0.2f %0.2f",
             s_or, s_mix.v, s_mix.tag, s_sr[0], s_sr[1]);
    $display("class resolvers: real max=%0.2f int max=%0d, plain shortreal=%0.2f", s_rmax,
             s_imax, s_plain);
    $display("undriven: plain_nib=%b wire=%b", s_undriven, w_undriven);
    $display("arrays: arr=%0d %0d parr=%b %b", arr[0], arr[1], parr[0], parr[1]);
    #9 a = 4'd1;
    #1 $display("t=11: s_add=%0d s_del=%0d s_del2=%0d", s_add, s_del, s_del2);
    #3 $display("t=14: s_add=%0d s_del=%0d", s_add, s_del);
    #6 a = 4'd3;
    #1 $display("t=21: s_add=%0d arr=%0d %0d", s_add, arr[0], arr[1]);
  end
endmodule
