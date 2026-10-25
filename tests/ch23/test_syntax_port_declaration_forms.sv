/*
:name: test_syntax_port_declaration_forms
:description: Every form of ANSI port declaration header: a net header with net type and unpacked dimensions, a variable header with var, a named interface header with and without a modport, a generic interface header with and without a modport, a default value on an input, an inherited direction and type, each direction, and an empty port list (IEEE 1800-2023 Section 23.2.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.2 23.2.2.3 23.2.2.4 A.1.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_port_declaration_forms.expected
*/
// IEEE 1800-2023 23.2.2.2, 23.2.2.3 and A.1.3. The header of ansi_headers
// has
//   - net ports with a net type, a data type, two unpacked dimensions and a
//     default value on an input (n_a, n_b, n_c),
//   - variable ports with var and a default value (step, dflt, cnt),
//   - a ref port, which is a variable, and an inout port, which is a net,
//   - a port with no header of its own (i2), which inherits the direction
//     and the type of the port before it,
//   - a named interface port with a modport (m) and one without (plain).
// The header of ansi_generic has generic interface ports with a modport (s)
// and without one (gen).
// ansi_empty shows the empty list that A.1.3 allows.
//
// Each port that carries a value is read into a printed number. The default
// value of the unconnected input n_c is read through the instance, and the
// ref port writes to the variable of the parent, so a port that is not
// connected as its direction says changes a number or leaves it behind.
//
// Icarus Verilog 13.0 does not support interface ports in a header. Verilator
// 5.052 does not accept a generic interface port and a port of a named
// interface in one header, so the two kinds are in two modules, which it
// accepts.

interface ifc;
  logic [7:0] data;
  logic valid;
  modport master (output data, output valid);
  modport slave (input data, input valid);
endinterface

module ansi_headers (
  (* keep *) input wire [7:0] n_a,
  input  wire [7:0] n_b [2],
  input  wire [7:0] n_c = 8'h3,
  output logic [7:0] v_y,
  inout  tri [7:0] io,
  ref    int r,
  input  var int step,
  input  var int dflt = 5,
  output var int cnt,
  input  logic [1:0] i1, i2,
  ifc.master m,
  ifc plain
);
  assign v_y = n_a + n_b[0] + n_b[1] + step + i1 + i2 + plain.data + io;
  assign m.data = v_y;
  assign m.valid = 1;
  assign plain.data = 8'h9;

  initial begin
    r = r + 100;
    cnt = 7;
  end
endmodule

module ansi_generic (
  interface.slave s,
  interface gen,
  output logic [7:0] sum
);
  assign sum = s.data + gen.data;
endmodule

module ansi_empty ();

  initial #2 $display("ansi_empty elaborated");
endmodule

module test_syntax_port_declaration_forms;
  logic [7:0] n_a = 8'd1;
  logic [7:0] nb [2];
  logic [3:0] i1 = 2'd1, i2 = 2'd1;
  logic [7:0] vy, gsum;
  tri [7:0] bus;
  int rv = 10, cnt_o, step_v = 2;
  ifc ifc_m();
  ifc ifc_p();
  ifc ifc_s();
  ifc ifc_g();

  assign bus = 8'd1;

  ansi_headers u_a (.n_a(n_a), .n_b(nb), .v_y(vy), .io(bus),
                    .r(rv), .step(step_v), .cnt(cnt_o), .i1(i1), .i2(i2),
                    .m(ifc_m), .plain(ifc_p));

  ansi_generic u_g (.s(ifc_s), .gen(ifc_g), .sum(gsum));

  ansi_empty u_ae ();

  initial begin
    nb[0] = 8'd2;
    nb[1] = 8'd3;
    ifc_s.data = 8'd4;
    ifc_g.data = 8'd6;
    #1 $display("ansi: vy=%0d m=%0d plain=%0d gen_sum=%0d io=%0d cnt=%0d r=%0d",
                vy, ifc_m.data, ifc_p.data, gsum, bus, cnt_o, rv);
    $display("ansi: n_c=%0d dflt=%0d step=%0d", u_a.n_c, u_a.dflt, u_a.step);
  end
endmodule
