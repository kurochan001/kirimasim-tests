/*
:name: test_syntax_udp_table_symbols
:description: combinational and sequential UDP tables using every level, output and edge symbol, edge indicators before, between and after level symbols, current-state and next-state fields and an initial statement (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.6 29.3.4 29.3.5 29.4 29.5 29.6 29.9 29.7 A.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_udp_table_symbols.expected
*/
// IEEE 1800-2023 A.5.3, §29.3.4: a UDP body is a combinational table (rows
// of level symbols, a colon and an output symbol) or a sequential one (an
// optional initial statement, then rows of inputs, the current state and the
// next state). An input list of a sequential row has at most one edge
// indicator, a pair of level symbols in parentheses or an edge symbol, with
// level symbols on either side. §29.3.6, Table 29-1: x and X are unknown,
// ? is 0, 1 or x, b and B are 0 or 1, - keeps the state, r and R are (01), f
// and F are (10), p and P are (01), (0x) or (x1), n and N are (10), (1x) or
// (x0), and * is any change. §29.4, §29.6: a combination that no row covers
// gives x. §29.3.5: a z input is taken as x. §29.9: a level row that matches
// decides over the edge rows.
//
// u_comb uses the level symbols and the output symbols. u_ff is a rising-
// edge flip-flop (r, R) that ignores n edges of the clock and * changes of
// the data and is set while e is 0 (a level row); its initial value 1 is
// kept until the first edge. u_pn loads d on p and P edges, including (0x)
// and (x1), which an r edge does not cover, and ignores N edges and F and
// (01) changes of d. u_tog toggles on r, keeps its state on f, and leaves
// the state x on an undeclared (0x) edge, from which an r edge gives 1.

primitive u_comb (y, i0, i1, i2);
  output y;
  input i0, i1, i2;
  table
  // i0 i1 i2 : y
     0 0 ? : 0;
     0 1 ? : 1;
     0 x ? : X;
     1 b 0 : 1;
     1 B 1 : 0;
     1 X ? : 0;
     x ? ? : x;
  endtable
endprimitive

primitive u_ff (q, c, d, e);
  output q;
  reg q;
  input c, d, e;
  initial q = 1'b1;
  table
  // c  d  e    : q : q+
     r  0  1    : ? : 0;
     R  1  1    : ? : 1;
     n  ?  ?    : ? : -;
     ?  *  ?    : ? : -;
     ?  ?  0    : ? : 1;
     ?  ?  (?1) : ? : -;
  endtable
endprimitive

primitive u_pn (q, c, d);
  output q;
  reg q;
  input c, d;
  table
  // c  d    : q : q+
     P  0    : ? : 0;
     p  1    : ? : 1;
     N  ?    : ? : -;
     ?  F    : ? : -;
     ?  (01) : ? : -;
     ?  (x?) : ? : -;
  endtable
endprimitive

primitive u_tog (q, t);
  output q;
  reg q;
  input t;
  initial q = 0;
  table
  // t    : q : q+
     r    : 0 : 1;
     r    : 1 : 0;
     r    : x : 1;
     f    : ? : -;
     (x0) : ? : -;
  endtable
endprimitive

module test_syntax_udp_table_symbols;
  reg a, b, c;
  reg fc, fd, fe;
  reg pc, pd;
  reg t;
  wire y, fq, pq, tq;

  u_comb g1 (y, a, b, c);
  u_ff   g2 (fq, fc, fd, fe);
  u_pn   g3 (pq, pc, pd);
  u_tog  g4 (tq, t);

  task comb(input logic [2:0] v);
    {a, b, c} = v;
    #1 $display("comb abc=%b%b%b y=%b", a, b, c, y);
  endtask

  task ff(input string what);
    #1 $display("ff %s q=%b", what, fq);
  endtask

  task pn(input string what);
    #1 $display("pn %s q=%b", what, pq);
  endtask

  task tog(input string what);
    #1 $display("tog %s q=%b", what, tq);
  endtask

  initial begin
    comb(3'b00x);
    comb(3'b010);
    comb(3'b0z1);
    comb(3'b100);
    comb(3'b110);
    comb(3'b111);
    comb(3'b1x1);
    comb(3'b10x);
    comb(3'bx10);

    fc = 0; fd = 0; fe = 1;
    ff("initial");
    fc = 1;      ff("r d=0");
    fc = 0;
    fd = 1;      ff("n, *");
    fc = 1;      ff("R d=1");
    fc = 0;
    fd = 0;
    #1 fc = 1;   ff("r d=0");
    fe = 0;      ff("e=0");
    fc = 0;
    #1 fc = 1;   ff("r e=0");
    fe = 1;      ff("e rises");
    fc = 0;
    #1 fc = 1;   ff("r d=0");

    pc = 0; pd = 1;
    pn("start");
    pc = 1'bx;   pn("(0x) d=1");
    pd = 0;      pn("(10) on d");
    pc = 1;      pn("(x1) d=0");
    pc = 1'bx;   pn("(1x)");
    pc = 0;      pn("(x0)");
    pd = 1;      pn("(01) on d");
    pc = 1;      pn("(01) d=1");

    t = 0;
    tog("initial");
    t = 1;       tog("r");
    t = 0;       tog("f");
    t = 1;       tog("r");
    t = 0;
    #1 t = 1'bx; tog("(0x)");
    t = 0;       tog("(x0)");
    t = 1;       tog("r from x");
  end
endmodule
