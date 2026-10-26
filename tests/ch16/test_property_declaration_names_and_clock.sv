/*
:name: test_property_declaration_names_and_clock
:description: A named property may be written with formals, an assertion variable declaration, a clock or none, and a closing label, and it is instantiated by an ordinary or hierarchical name with non-formal variables resolved where it is declared; a clock-free property takes the default clocking (IEEE 1800-2023 Sections 16.12, 16.12.20 and 14.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.20 16.12 14.12 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_declaration_names_and_clock.expected
*/
// IEEE 1800-2023 §16.12: a property declaration has property/endproperty,
// optional formals, optional assertion variable declarations and a
// property_spec, and may end with a label. §16.12.20: a property may specify a
// clocking event; it may also be instantiated by an ordinary or a hierarchical
// name, and non-formal variables resolve from the scope of the declaration.
// §14.12: a property that does not specify a clock uses the default clocking
// where the assertion statement is.
//
// p_clocked names its clock, so a_own, which gives no outer clock, and a_over,
// which gives the outer clock cb2, both run on clk. p_plain has no clock and
// a_default runs it under the default clocking clk. a_formal instantiates
// p_formal with a, and p_local declares a local variable, assigns it at the
// first tick and compares it at the next one, so its attempts from 5, 15 and
// 25 pass at 15, 25 and 35; the attempt from 35 needs a tick at 45 and is
// pending. p_hier is declared in sub with the clock cb and the variable v of
// sub; a_hier instantiates it by the hierarchical name u1.p_hier, so it passes
// at the cb ticks, which shows that cb and v resolve in sub. p_unused is a
// property declaration that no assertion statement uses, so it produces no
// verification result; the last line only records that the design ran.
// Icarus Verilog 13.0 does not support concurrent assertions; Verilator 5.052
// does not support a hierarchical property name or a clock-free property under
// a default clocking here, so the expected values come from the cited clauses.

`timescale 1ns/1ns

module sub;
  logic cb = 0, v = 1;

  property p_hier;
    @(posedge cb) v;
  endproperty : p_hier
endmodule

module test_property_declaration_names_and_clock;
  logic clk = 0, cb2 = 0, a = 1;
  int q_own[$], q_over[$], q_default[$], q_formal[$], q_hier[$], q_local[$];

  sub u1();

  default clocking @(posedge clk); endclocking

  always #5 clk = ~clk;   // rising edges at 5, 15, 25 and 35

  initial begin
    #7 cb2 = 1;
    forever begin
      #5 cb2 = 0;
      #5 cb2 = 1;
    end
  end

  initial begin
    #10 u1.cb = 1;
    forever begin
      #5 u1.cb = 0;
      #5 u1.cb = 1;
    end
  end

  property p_clocked;
    @(posedge clk) a;
  endproperty

  property p_plain;
    a;
  endproperty

  property p_formal(x);
    x;
  endproperty

  property p_local(x);
    int v;
    @(posedge clk) (1'b1, v = x) ##1 (v == x);
  endproperty : p_local

  property p_unused;
    @(posedge clk) 1'b0;
  endproperty

  a_own: assert property (p_clocked) q_own.push_back($time);
  a_over: assert property (@(posedge cb2) p_clocked) q_over.push_back($time);
  a_default: assert property (p_plain) q_default.push_back($time);
  a_formal: assert property (@(posedge clk) p_formal(a)) q_formal.push_back($time);
  a_hier: assert property (u1.p_hier) q_hier.push_back($time);
  a_local: assert property (p_local(a)) q_local.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #43;
    $display("explicit clock property without outer clock:%s", times(q_own));
    $display("explicit clock over an outer cb2:%s", times(q_over));
    $display("clock-free property under default clocking:%s", times(q_default));
    $display("formal property passes:%s", times(q_formal));
    $display("hierarchical property passes:%s", times(q_hier));
    $display("local variable property passes:%s", times(q_local));
    $display("unused property declared");
    $finish;
  end
endmodule
