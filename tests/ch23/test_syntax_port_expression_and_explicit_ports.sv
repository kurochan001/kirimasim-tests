/*
:name: test_syntax_port_expression_and_explicit_ports
:description: A non-ANSI port list with a concatenation, a part-select and a simple port expression, explicit ports with an expression and with none, an explicit port in an ANSI header, the four port directions with attributes in non-ANSI declarations, an interface port declaration with and without a modport, and an empty non-ANSI port list (IEEE 1800-2023 Section 23.2.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.1 23.2.2.2 23.2.2.3 A.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_port_expression_and_explicit_ports.expected
*/
// IEEE 1800-2023 23.2.2.1, 23.2.2.2 and A.1.3. A port expression is a port
// reference, a bit- or part-select of one, or a concatenation of them; a port
// is that expression, or a dot, a port name and parentheses around an
// optional port expression.
//   - nonansi_ports lists {p, q}, part[1:0], .named(b) and .nc(), then the
//     implicit ports io, rr, m, plain and sum. Its port declarations use an
//     attribute, a net type (wire, tri), a variable type (logic, int), the
//     directions input, inout, ref and output, and interface ports with and
//     without a modport.
//   - explicit_ports has only explicitly named ANSI ports: three with an
//     expression and one (unused) without one.
//   - nonansi_empty has the empty non-ANSI list.
//
// The sum adds the four port expressions, so a port that carries the wrong
// slice or the wrong concatenation changes the number; the ref port writes to
// the parent's variable; the interface ports drive signals the parent reads.
// The null ports .nc() and .unused() have no port expression, so the
// instances leave them unconnected: a blank ordered connection (23.3.2.1) and
// empty parentheses after the port name (23.3.2.2).
//
// No release compiles this: Icarus Verilog 13.0 rejects interface ports and
// every complex port; Verilator 5.052 rejects complex ports.

interface ifc;
  logic [7:0] data;
  logic valid;
  modport master (output data, output valid);
  modport slave (input data, input valid);
endinterface

module nonansi_ports ({p, q}, part[1:0], .named(b), .nc(), io, rr, m, plain, sum);
  (* keep *) input wire [1:0] p, q;
  input logic [3:0] part;
  input logic [2:0] b;
  inout tri [3:0] io;
  ref int rr;
  ifc.master m;
  ifc plain;
  output logic [7:0] sum;

  assign sum = {p, q} + part[1:0] + b + io;
  assign m.data = 8'h11;
  assign m.valid = 0;
  assign plain.data = 8'h22;

  initial rr = rr + 5;
endmodule

module explicit_ports (
  output .hi(r[7:4]),
  output .lo(r[3:0]),
  input  .low_in(w[3:0]),
  ref    .cell_v(v[1]),
  input  .unused()
);
  logic [7:0] r;
  logic [7:0] w = 8'h30;
  int v [2];

  initial r = 8'hA5;
  initial #2 v[1] = v[1] + 2;
endmodule

module nonansi_empty ();

  initial #4 $display("nonansi_empty elaborated");
endmodule

module test_syntax_port_expression_and_explicit_ports;
  logic [1:0] p = 2'd2, q = 2'd1;
  logic [1:0] pv = 2'b01;
  logic [2:0] bv = 3'd2;
  tri [3:0] bus;
  int rv = 10;
  logic [7:0] sum;
  wire [7:0] hi, lo;
  int cellv [2] = '{0, 40};
  ifc np_m();
  ifc np_p();

  assign bus = 4'd3;

  nonansi_ports u_np({p, q}, pv, bv, , bus, rv, np_m, np_p, sum);
  explicit_ports u_ep (.hi(hi), .lo(lo), .low_in(4'h3), .cell_v(cellv[1]),
                       .unused());
  nonansi_empty u_ne ();

  initial begin
    #1 $display("nonansi: sum=%0d rr=%0d m=%0d plain=%0d io=%0d",
                sum, rv, np_m.data, np_p.data, bus);
    #1 $display("explicit: hi=%h lo=%h low=%h", hi, lo, u_ep.w[3:0]);
    #1 $display("explicit: cell=%0d", cellv[1]);
  end
endmodule
