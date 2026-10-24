/*
:name: test_primitive_terminal_lists
:description: each kind of gate and switch takes its terminals in its own order, outputs and bidirectional terminals first and inputs after them (IEEE 1800-2023 Section 28.3)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3 28.3.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_primitive_terminal_lists.expected
*/
// IEEE 1800-2023 §28.3, Syntax 28-1, gives each kind of primitive its
// terminals: a cmos switch an output, a data input, an n-channel and a
// p-channel control; a MOS switch and an enable gate an output, a data
// input and an enable; a pass switch two inout terminals and, for the
// tranif forms, an enable; an n-input gate one output and then its inputs;
// an n-output gate its outputs and then one input; a pull gate one output.
// §28.3.6: the terminals are separated by commas inside parentheses, the
// outputs and bidirectional terminals first. Output and inout terminals
// are net lvalues, here bits of a vector net, and inputs are expressions.
// Three input patterns give each primitive a result that changes if its
// terminals were taken in another order; bit 7 of w is not driven.

module test_primitive_terminal_lists;
  logic a, b, c, en, nc, pc;
  wire [7:0] w;
  wire [1:0] t, ti;

  and     g_and (w[0], a, b, c);
  buf     g_buf (w[1], w[2], a ^ b);
  bufif1  g_bif (w[3], ~a, en);
  nmos    g_nm  (w[4], b, en);
  cmos    g_cm  (w[5], c, nc, pc);
  pullup  g_pu  (w[6]);
  tran    g_tr  (t[0], t[1]);
  tranif1 g_ti  (ti[0], ti[1], en);

  assign t[0] = a;
  assign ti[0] = b;

  initial begin
    a = 1; b = 0; c = 1; en = 1; nc = 1; pc = 1;
    #1 $display("abc=%b%b%b en=%b nc=%b pc=%b: w=%b tran=%b tranif1=%b",
                a, b, c, en, nc, pc, w, t[1], ti[1]);
    a = 1; b = 1; c = 1; en = 0; nc = 0; pc = 1;
    #1 $display("abc=%b%b%b en=%b nc=%b pc=%b: w=%b tran=%b tranif1=%b",
                a, b, c, en, nc, pc, w, t[1], ti[1]);
    a = 0; b = 1; c = 0; en = 1; nc = 0; pc = 0;
    #1 $display("abc=%b%b%b en=%b nc=%b pc=%b: w=%b tran=%b tranif1=%b",
                a, b, c, en, nc, pc, w, t[1], ti[1]);
  end
endmodule
