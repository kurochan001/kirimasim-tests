/*
:name: test_typename_signing_ranges_scopes
:description: $typename drops a signing that is the default of the type, keeps one that is not, writes ranges as unsized decimal numbers, uses $ for the name of an unpacked array, prefixes a user-defined type with its package or scope, and keeps only single spaces between keywords and identifiers (IEEE 1800-2023 Section 20.6.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typename_signing_ranges_scopes.expected
*/
// IEEE 1800-2023 §20.6.1 builds the string of $typename in steps: b) the
// default signing of a type is removed even when the source writes it, so
// int signed is "int" but int unsigned keeps "unsigned"; d) "$" stands for
// the name of an anonymous unpacked array, before its unpacked range; f) a
// user-defined type is prefixed with the package (pkg::) or scope (scope.)
// that defines it; g) ranges are shown as unsized decimal numbers; h) white
// space of the source is removed and a single space separates identifiers
// and keywords.
// Line 1 shows types whose written signing is their default; line 2 types
// whose signing is not, declared with extra spaces. Lines 3 and 4 show the
// part of the string from the first "[" or "$" on, for packed ranges written
// with sized, based and spaced bounds and for unpacked arrays, so that they
// do not depend on what comes before the range. Lines 5 and 6 show an
// unpacked structure type from a package and one from this module, the
// second written with extra spaces.
// Icarus Verilog 13.0 does not support unpacked structures, and release
// 5.052 of the Verilator tool drops the signing that is not the default
// (line 2 becomes [int][bit][logic][shortint]).

package tn_scope_pkg;
  typedef struct {bit a; bit b;} pair_t;
endpackage

module test_typename_signing_ranges_scopes;
  typedef struct {  bit   x ;  bit  y ; } local_t;

  int signed s1;
  byte signed s2;
  integer signed s3;
  bit unsigned s4;
  logic unsigned s5;
  int    unsigned k1;
  bit   signed k2;
  logic  signed k3;
  shortint   unsigned k4;
  logic [4'hF:2'b10] r1;
  logic [ 7 : 0 ] r2;
  bit [1'b1:3'd4] r3;
  int ua [8'd3:8'h1];
  byte ub [2];
  tn_scope_pkg::pair_t pv;
  local_t lv;

  function automatic string from(string s, byte c);
    for (int i = 0; i < s.len(); i++)
      if (s[i] == c) return s.substr(i, s.len() - 1);
    return "";
  endfunction

  initial begin
    $display("[%s][%s][%s][%s][%s]", $typename(s1), $typename(s2), $typename(s3),
             $typename(s4), $typename(s5));
    $display("[%s][%s][%s][%s]", $typename(k1), $typename(k2), $typename(k3), $typename(k4));
    $display("%s %s %s", from($typename(r1), "["), from($typename(r2), "["),
             from($typename(r3), "["));
    $display("%s %s", from($typename(ua), "$"), from($typename(ub), "$"));
    $display("%s", $typename(pv));
    $display("%s", $typename(lv));
  end
endmodule
