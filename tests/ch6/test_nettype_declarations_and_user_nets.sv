/*
:name: test_nettype_declarations_and_user_nets
:description: nettype declarations without a resolution function, with one named directly, through a package or through a class, and new names for a nettype with and without a package scope; nets of these nettypes declared with a delay and a list of net declaration assignments, observed through resolved values and change times (IEEE 1800-2023 Sections 6.6.7, 6.7.2, A.2.1.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.7 6.7.2 6.7.3 10.3.3 A.2.1.3 A.2.3 A.2.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nettype_declarations_and_user_nets.expected
*/
// IEEE 1800-2023 A.2.1.3: a nettype declaration either names a data type
// with an optional "with" and a resolution function, which may carry a
// package or class scope, or gives a new name to a nettype, which may carry a
// package or class scope. A net of a user-defined nettype is declared with
// the nettype name, an optional delay control and a list of net declaration
// assignments (A.2.3, A.2.4).
// - §6.6.7: the net uses the data type of its nettype and calls its
//   resolution function, which gets the values of all drivers; a new name
//   for a nettype keeps its data type and function. Here rsum adds, Res::rmax
//   takes the largest and rmin the smallest driver value.
// - §6.7.3: a net of a nettype without a resolution function and without a
//   driver keeps the default value of its type, x for logic [3:0].
// - §10.3.3: on a net of a user-defined nettype one delay applies to any
//   change. ns_a gets src_v 3 units later through the assignment of its
//   declaration; ns_b, declared in the same list without one, has the net
//   delay 3 for the changes of its two drivers.
// src_v changes at 10 and src_w at 20; values are printed one unit after a
// change, while the delayed nets still hold the old value, and once the
// delay has passed. Neither Icarus Verilog 13.0 nor the other release
// supports nettype declarations; the expected output follows the clauses.

`timescale 1ns/1ns

package pk;
  function automatic int rsum(input int drv []);
    rsum = 0;
    foreach (drv[i]) rsum += drv[i];
  endfunction

  nettype int pk_nt with rsum;
endpackage

class Res;
  static function int rmax(input int drv []);
    rmax = 0;
    foreach (drv[i]) if (drv[i] > rmax) rmax = drv[i];
  endfunction
endclass

module test_nettype_declarations_and_user_nets;
  function automatic int rmin(input int drv []);
    rmin = 1000;
    foreach (drv[i]) if (drv[i] < rmin) rmin = drv[i];
  endfunction

  nettype logic [3:0] nt_plain;
  nettype int nt_sum with pk::rsum;
  nettype int nt_max with Res::rmax;
  nettype int nt_min with rmin;
  nettype nt_sum nt_alias;
  nettype pk::pk_nt nt_pk_alias;

  int src_v = 5, src_w = 6;

  nt_sum #3 ns_a = src_v, ns_b;
  nt_plain np_d = 4'h9, np_u;
  nt_max nm;
  nt_min nn;
  nt_alias nal;
  nt_pk_alias npk;

  assign ns_b = 4;
  assign ns_b = src_w;
  assign nm = 7;
  assign nm = src_w;
  assign nn = 7;
  assign nn = src_w;
  assign nal = 10;
  assign nal = src_w;
  assign npk = 1;
  assign npk = 2;
  assign npk = src_w;

  initial begin
    #1 $display("t=%0t np_d=%h np_u=%h nm=%0d nn=%0d nal=%0d npk=%0d", $time, np_d, np_u, nm,
                nn, nal, npk);
    #9 src_v = 8;
    #1 $display("t=%0t ns_a=%0d ns_b=%0d", $time, ns_a, ns_b);
    #3 $display("t=%0t ns_a=%0d ns_b=%0d", $time, ns_a, ns_b);
    #6 src_w = 9;
    #1 $display("t=%0t ns_b=%0d nm=%0d nn=%0d nal=%0d npk=%0d", $time, ns_b, nm, nn, nal, npk);
    #3 $display("t=%0t ns_b=%0d", $time, ns_b);
  end
endmodule
