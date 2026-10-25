/*
:name: test_default_clocking_assertion_clocks
:description: a concurrent assertion without its own leading clock in a module, interface, program or checker with a default clocking is clocked by the default clocking, an explicit leading clock takes its place, a property declared outside the clocking block gets no clock from the default, one declared in the default clocking block has its clock, and of two juxtaposed clocks the inner one counts (IEEE 1800-2023 Section 16.16)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16 16.13.3 14.12 25.3 24.3 17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_clocking_assertion_clocks.expected
*/
// IEEE 1800-2023 §16.16: in a module, interface, program or checker with a
// default clocking (§14.12), a concurrent assertion with no other leading
// clock is treated as if the default clocking event were written as its
// leading clock (rule a); an explicit leading clock takes precedence (rule
// d). The default does not apply to a sequence or property declaration,
// except one declared in the clocking block that is the default, which has
// that clock. §16.13.3: of two juxtaposed clocking events the first is
// ignored, so @(posedge fclk) dcb.p_in is checked at the ticks of dclk only.
// clk ticks at 5, 15, ..., the default dclk at 8, 18, ..., fclk at 2, 6, 10,
// ...; each assertion fails (t |-> 1'b0) only where its own t is high, in a
// window around one tick, and prints the time from its fail action, which
// shows the clock that was used. a_def and a_ncd (the property p_ncd) fail at
// the dclk ticks 28 and 68; a_exp and a_nc (@(posedge clk) p_nc) at the clk
// ticks 35 and 45; a_in at the dclk tick 58, once, although t_in is also
// high at the fclk tick 54; the assertions of the
// interface (§25.3), the program (§24.3) and the checker (§17.2), each with
// its own default clocking on dclk, at 78, 88 and 98. Icarus Verilog 13.0
// does not support these assertions, and the 5.052 release of Verilator
// does not support property declarations in a clocking block.

`timescale 1ns/1ns

interface dc_if(input logic dclk, t);
  default clocking @(posedge dclk); endclocking
  a_if: assert property (t |-> 1'b0) else $display("%0d: a_if", $time);
endinterface

program dc_prog(input logic dclk, t);
  default clocking @(posedge dclk); endclocking
  a_prog: assert property (t |-> 1'b0) else $display("%0d: a_prog", $time);
endprogram

checker dc_chk(logic dclk, logic t);
  default clocking @(posedge dclk); endclocking
  a_chk: assert property (t |-> 1'b0) else $display("%0d: a_chk", $time);
endchecker

module test_default_clocking_assertion_clocks;
  logic clk = 0, dclk = 0, fclk = 0;
  logic t_def = 0, t_exp = 0, t_nc = 0, t_in = 0, t_ncd = 0, t_if = 0, t_prog = 0, t_chk = 0;

  always #5 clk = ~clk;    // rising at 5, 15, 25, ...
  always #2 fclk = ~fclk;  // rising at 2, 6, 10, ...

  initial begin
    #8;
    forever begin
      dclk = ~dclk;        // rising at 8, 18, 28, ...
      #5;
    end
  end

  default clocking dcb @(posedge dclk);
    property p_in;
      t_in |-> 1'b0;
    endproperty
  endclocking

  property p_nc;
    t_nc |-> 1'b0;
  endproperty

  property p_ncd;
    t_ncd |-> 1'b0;
  endproperty

  a_def: assert property (t_def |-> 1'b0) else $display("%0d: a_def", $time);
  a_exp: assert property (@(posedge clk) t_exp |-> 1'b0) else $display("%0d: a_exp", $time);
  a_nc: assert property (@(posedge clk) p_nc) else $display("%0d: a_nc", $time);
  a_in: assert property (@(posedge fclk) dcb.p_in) else $display("%0d: a_in", $time);
  a_ncd: assert property (p_ncd) else $display("%0d: a_ncd", $time);

  dc_if u_if(dclk, t_if);
  dc_prog u_prog(dclk, t_prog);
  dc_chk u_chk(dclk, t_chk);

  // Raises s from time t0 to t1.
  task automatic window(ref logic s, input int t0, t1);
    #(t0 - $time) s = 1;
    #(t1 - t0) s = 0;
  endtask

  initial begin
    window(t_def, 26, 29);
    window(t_exp, 33, 36);
    window(t_nc, 43, 46);
    window(t_in, 53, 59);
    window(t_ncd, 66, 69);
    window(t_if, 76, 79);
    window(t_prog, 86, 89);
    window(t_chk, 96, 99);
    #11 $finish;
  end
endmodule
