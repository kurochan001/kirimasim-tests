/*
:name: test_gate_declaration_list_names_ranges_terminals
:description: gate and switch declarations with the keyword, a shared drive strength and delay, a comma-separated list of named and unnamed instances, an instance array with a range, expressions as input and control terminals and nets or net bit-selects as output and inout terminals (IEEE 1800-2023 Section 28.3)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_declaration_list_names_ranges_terminals.expected
*/
// IEEE 1800-2023 §28.3 (Syntax 28-1): a gate or switch declaration has the
// keyword of the primitive, an optional drive strength and an optional delay
// where its type allows them, and a comma-separated list of instances that
// share them; each instance has an optional name, an optional range that
// makes an array of instances, and its terminal list. Input, enable and
// control terminals are expressions; output and inout terminals are net
// lvalues.
//
// - and (strong0, pull1) #(2, 3) has the named instance g_a on a & b and an
//   unnamed one on a & ~b: both drive St0 or Pu1, and change 2 after a rise
//   and 3 after a fall.
// - buf (weak1, weak0) has two outputs, the net o1 and the bit-select
//   bus[0], and the input expression a ^ b: We0 or We1.
// - bufif1 #2 has the constant input 1'b1 and the enable en; nmos passes b
//   and cmos passes a under the control expressions en and !en.
// - nand g_n [3:0] is an array of four instances on the 4-bit nets and
//   variables ny, av and bv, one bit each: ~(0011 & 0101) is 1110.
// - tran connects the net t1, which b drives, to the bit-select bus[1].
// a, b and en are 0 until 10, become 1 at 10, and b becomes 0 at 20. The
// values are printed at 5, 11, 13, 21 and 24, between the changes.
// The cmos switch is not supported by Verilator 5.054.

`timescale 1ns/1ns

module test_gate_declaration_list_names_ranges_terminals;
  logic a = 1'b0, b = 1'b0, en = 1'b0;
  logic [3:0] av = 4'b0011, bv = 4'b0101;
  wire y1, y2, o1, ye, ym, yc, t1;
  wire [2:0] bus;
  wire [3:0] ny;

  and (strong0, pull1) #(2, 3) g_a (y1, a, b), (y2, a, ~b);
  buf (weak1, weak0) g_b (o1, bus[0], a ^ b);
  bufif1 #2 g_e (ye, 1'b1, en);
  nmos g_m (ym, b, en);
  cmos (yc, a, en, !en);
  nand g_n [3:0] (ny, av, bv);
  tran (t1, bus[1]);
  assign t1 = b;

  task automatic show();
    $display("t=%0t: y1 %v, y2 %v, o1 %v, bus[0] %b, ye %v, ym %v, yc %v, bus[1] %b, ny %b",
             $time, y1, y2, o1, bus[0], ye, ym, yc, bus[1], ny);
  endtask

  initial begin
    #5 show();
    #5 {a, b, en} = 3'b111;
    #1 show();
    #2 show();
    #7 b = 1'b0;
    #1 show();
    #3 show();
  end
endmodule
