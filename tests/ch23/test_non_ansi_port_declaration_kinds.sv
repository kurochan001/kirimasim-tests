/*
:name: test_non_ansi_port_declaration_kinds
:description: non-ANSI input, output, inout and ref port declarations with net and variable port types, lists of several ports, unpacked dimensions and an initialized output variable (IEEE 1800-2023 Sections 23.2.2.1, A.2.1.2, A.2.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.1 23.2.2.3 23.3.3.2 A.2.1.2 A.2.2.1 A.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_non_ansi_port_declaration_kinds.expected
*/
// IEEE 1800-2023 §23.2.2.1 and A.2.1.2: in a non-ANSI port declaration
// - input takes a net port type and a list of port identifiers, or a
//   variable port type and a list of variable identifiers;
// - output takes a net port type and a list of port identifiers, or a
//   variable port type and a list of variable port identifiers, each of
//   which can have an initial value;
// - inout takes a net port type and a list of port identifiers;
// - ref takes a variable port type and a list of variable identifiers.
// A.2.2.1: a net port type is an optional net type with a data type or an
// implicit type; a variable port type is a data type, or var with a data type
// or an implicit type. A.2.3: every list has one or more comma-separated
// names, each with unpacked (or variable) dimensions of its own.
// In np_child:
// - ia and ib[2] are wire [3:0] inputs, il an input of data type logic [3:0]
//   without a net type, which makes it a net (§23.2.2.3);
// - iv[2] and iw are var int inputs, vs a var signed [3:0] input: vs = -2
//   gives oi = vs * 3 = -6, which needs the signed implicit type;
// - oa is a tri [7:0] output driven by a continuous assignment, oi an output
//   whose data type int makes it a variable, ov and ox[2] var logic [7:0]
//   outputs, where ov starts at 8'h3c before the child assigns it at time 5;
// - io and ip are wire [3:0] inouts carrying values both ways: the parent
//   drives ip with 9 and the child drives io with ip + 1;
// - rv and rw[2] are var int ref ports, which make the child use the
//   parent's variables (§23.3.3.2): the child's writes at time 5 are seen by
//   the parent at 6, and the parent's writes at 6 by the child at 7.

module np_child(ia, ib, il, iv, iw, vs, oa, oi, ov, ox, io, ip, rv, rw);
  input wire [3:0] ia, ib [2];
  input logic [3:0] il;
  input var int iv [2], iw;
  input var signed [3:0] vs;
  output tri [7:0] oa;
  output int oi;
  output var logic [7:0] ov = 8'h3c, ox [2];
  inout wire [3:0] io, ip;
  ref var int rv, rw [2];

  assign oa = {ia, ib[1]};
  assign io = ip + 4'd1;

  initial begin
    #5;
    oi = vs * 3;
    ov = iv[0] + iv[1] + iw;
    ox[0] = {il, 4'h1};
    ox[1] = {ip, ia};
    rv = 7;
    rw[1] = 9;
    #2 $display("t7 child rv=%0d rw0=%0d", rv, rw[0]);
  end
endmodule

module test_non_ansi_port_declaration_kinds;
  logic [3:0] a = 4'h5, l = 4'hc;
  logic [3:0] b [2] = '{4'h1, 4'h2};
  int v [2] = '{10, 20};
  int w = 3;
  logic signed [3:0] s = -2;
  wire [7:0] oa;
  int oi;
  logic [7:0] ov, ox [2];
  wire [3:0] io, ip;
  int x = 1;
  int y [2] = '{0, 0};

  assign ip = 4'h9;

  np_child u (a, b, l, v, w, s, oa, oi, ov, ox, io, ip, x, y);

  initial begin
    #1 $display("t1 oa=%h ov=%h io=%h", oa, ov, io);
    #5 $display("t6 oi=%0d ov=%0d ox=%h,%h x=%0d y1=%0d", oi, ov, ox[0], ox[1], x, y[1]);
    x = 42;
    y[0] = 5;
  end
endmodule
