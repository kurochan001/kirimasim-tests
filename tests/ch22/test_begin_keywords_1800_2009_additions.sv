/*
:name: test_begin_keywords_1800_2009_additions
:description: under `begin_keywords "1800-2009" the 23 words that IEEE Std 1800-2009 added are keywords, used in let, checker, unique0, global clocking, sequence and property declarations, while under "1800-2005" the same words are ordinary variable names (IEEE 1800-2023 Section 22.14.7)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14.7 22.14 22.14.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_keywords_1800_2009_additions.expected
*/
// IEEE 1800-2023 §22.14.7: the version specifier "1800-2009" reserves the
// keywords of the earlier versions and the words of Table 22-5. §22.14.6:
// "1800-2005" does not reserve those words.
//   - kw2005_names, under "1800-2005", declares all 23 words as int
//     variables with the values 1 to 23 and prints their sum, 276.
//   - The rest of the file is under "1800-2009" and uses every word in its
//     keyword role: checker and endchecker delimit kw09_chk; untyped types
//     the formals of the checker, of a let and of a sequence; let declares
//     add1 and pick; global starts a global clocking declaration; restrict
//     starts a restrict assertion; unique0 starts a case statement; and
//     the property declarations use accept_on, reject_on, sync_accept_on,
//     sync_reject_on, eventually, s_eventually, nexttime, s_nexttime,
//     s_always, until, s_until, until_with, s_until_with, implies, strong
//     and weak. The properties are declared but never asserted, so only their
//     keywords matter; a word read as a plain name there is a syntax error.
//   - The module prints add1(4) = 5, pick(c, 7) = 7 with c = 1, and r = 20
//     from the unique0 case item for r = 2; the final procedure of the
//     checker prints its actual arguments a = 1 and add1(2) = 3 at the end.
// Each line is printed at its own time.
// Icarus Verilog 13.0 prints the first line alone but stops with a syntax
// error at the checker declaration. The 5.052 release of Verilator reserves
// restrict even under "1800-2005" and does not support eventually, nexttime
// and s_nexttime in property expressions.

`begin_keywords "1800-2005"
module kw2005_names;
  int accept_on = 1, checker = 2, endchecker = 3, eventually = 4, global = 5;
  int implies = 6, let = 7, nexttime = 8, reject_on = 9, restrict = 10;
  int s_always = 11, s_eventually = 12, s_nexttime = 13, s_until = 14;
  int s_until_with = 15, strong = 16, sync_accept_on = 17, sync_reject_on = 18;
  int unique0 = 19, until = 20, until_with = 21, untyped = 22, weak = 23;

  initial #1 $display("1800-2005 names: sum=%0d",
                      accept_on + checker + endchecker + eventually + global + implies + let
                      + nexttime + reject_on + restrict + s_always + s_eventually + s_nexttime
                      + s_until + s_until_with + strong + sync_accept_on + sync_reject_on
                      + unique0 + until + until_with + untyped + weak);
endmodule
`end_keywords

`begin_keywords "1800-2009"
checker kw09_chk(logic a, untyped b);
  final $display("checker: a=%0d b=%0d", a, b);
endchecker

module test_begin_keywords_1800_2009_additions;
  logic clk = 1'b0, a = 1'b1, b = 1'b0, c = 1'b1;
  int r = 2;

  let add1(x) = x + 1;
  let pick(untyped s, untyped t) = s ? t : 0;

  global clocking gclk @(posedge clk); endclocking

  sequence s_pair(untyped x, untyped y);
    x ##1 y;
  endsequence

  property p_accept;      @(posedge clk) accept_on (c) a ##1 b;      endproperty
  property p_reject;      @(posedge clk) reject_on (c) a ##1 b;      endproperty
  property p_sync_accept; @(posedge clk) sync_accept_on (c) a ##1 b; endproperty
  property p_sync_reject; @(posedge clk) sync_reject_on (c) a ##1 b; endproperty
  property p_eventually;  @(posedge clk) eventually [1:2] b;         endproperty
  property p_s_eventually; @(posedge clk) s_eventually b;            endproperty
  property p_nexttime;    @(posedge clk) nexttime a;                 endproperty
  property p_s_nexttime;  @(posedge clk) s_nexttime a;               endproperty
  property p_s_always;    @(posedge clk) s_always [0:1] a;           endproperty
  property p_until;       @(posedge clk) a until b;                  endproperty
  property p_s_until;     @(posedge clk) a s_until b;                endproperty
  property p_until_with;  @(posedge clk) a until_with b;             endproperty
  property p_s_until_with; @(posedge clk) a s_until_with b;          endproperty
  property p_implies;     @(posedge clk) a implies c;                endproperty
  property p_strong;      @(posedge clk) strong(s_pair(a, b));       endproperty
  property p_weak;        @(posedge clk) weak(s_pair(a, b));         endproperty

  restrict property (@(posedge clk) a);

  kw09_chk u_chk(a, add1(2));

  initial begin
    unique0 case (r)
      1: r = 10;
      2: r = 20;
    endcase
    #2 $display("1800-2009 keywords: add1=%0d pick=%0d r=%0d", add1(4), pick(c, 7), r);
  end
endmodule
`end_keywords
