/*
:name: test_pattern_casez_casex_ignored_bits
:description: In a pattern-matching case statement, casez ignores z bits and casex ignores x and z bits wherever two bits are compared, in the value and in the pattern and in structure member bits, while a plain case does not ignore them (IEEE 1800-2023 Section 12.6.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6.1 12.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pattern_casez_casex_ignored_bits.expected
*/
// IEEE 1800-2023 §12.6.1: casez and casex can replace case in a pattern
// matching case statement with the same semantics, except that during pattern
// matching, wherever two bits are compared, casez ignores z bits and casex
// ignores both z and x bits; this holds for tag bits and member bits alike.
// v is 4'b1x0z. A plain case does not ignore anything, so its first item
// 4'b1z0z fails on the x against z. casez ignores the z in the value and in
// the pattern and matches that item, but its second item 4'b100z fails on the
// x against 0. casex ignores the x and the z and matches 4'b100z, while
// 4'b1010 still fails on the 0 against 1. The packed structure s has the tag
// 2'b10 and the data 2'b1x: casex matches the pattern with data 2'b10, casez
// does not, and neither matches after the tag is changed to 2'b11.

module test_pattern_casez_casex_ignored_bits;
  typedef struct packed {
    logic [1:0] tag;
    logic [1:0] data;
  } s_t;

  logic [3:0] v;
  s_t s;

  initial begin
    v = 4'b1x0z;
    case (v) matches
      4'b1z0z: $display("case z: match");
      default: $display("case z: no");
    endcase
    casez (v) matches
      4'b1z0z: $display("casez z: match");
      4'b100z: $display("casez 0: match");
      default: $display("casez: no");
    endcase
    casex (v) matches
      4'b100z: $display("casex 0: match");
      default: $display("casex: no");
    endcase
    casex (v) matches
      4'b1010: $display("casex 1: match");
      default: $display("casex 1: no");
    endcase

    s = '{2'b10, 2'b1x};
    casex (s) matches
      '{2'b10, 2'b10}: $display("struct casex: match");
      default: $display("struct casex: no");
    endcase
    casez (s) matches
      '{2'b10, 2'b10}: $display("struct casez: match");
      default: $display("struct casez: no");
    endcase
    casex (s) matches
      '{2'b11, 2'b1?}: $display("struct tag: match");
      default: $display("struct tag: no");
    endcase
  end
endmodule
