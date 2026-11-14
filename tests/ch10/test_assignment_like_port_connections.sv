/*
:name: test_assignment_like_port_connections
:description: a connection to an input or output port of a module, an interface or a program is an assignment-like context, so an input takes an assignment pattern or an unpacked array concatenation of the port's type and an output of a structure or unpacked array type can be connected to a positional assignment pattern of variables (IEEE 1800-2023 Section 10.8)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.8 10.9 10.10
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_like_port_connections.expected
*/
// IEEE 1800-2023 §10.8: a port connection to an input or output port of a
// module, interface or program is an assignment-like context. §10.9: an
// assignment pattern without a type takes its type from the other side, and
// as the left-hand side it lists variables by position whose widths match
// the elements. §10.10: braces with an unpacked array target are an
// unpacked array concatenation. §23.3.3: an input or output port is a
// continuous assignment from the source to the sink.
// pair_t is a packed structure of two 8-bit members. A pattern of two ints
// gives one int to each member; as a vector concatenation it would be 64
// bits cut to 16, with hi = 0.
// The module alp_mod, the interface alp_if and the program alp_prog have the
// same ports: in_p (pair_t) and in_a (three bytes, unpacked) are inputs;
// out_p (pair_t) is an output that gives in_p with its members swapped and
// in_a[1] added to each, and out_a (two bytes, unpacked) is an output that
// gives in_a[2] and in_a[0]. Each instance connects a pattern of two ints
// to in_p, braces to in_a, and patterns of two byte variables to out_p and
// out_a: '{xh, xl} gets the hi and lo members, '{ya, yb} elements 0 and 1.
// The pattern on the packed out_p has the same bits as a concatenation of
// the two variables; on out_a only a pattern can be the target, since a
// 16-bit vector and an unpacked array are not assignment compatible (§7.6).
// The module and the interface use named connections, the program
// positional ones. Each instance prints its inputs at its own time; the
// top module prints the variables that the outputs drive at time 4. The
// program waits until time 10, so that the simulation does not end before
// (§24.3).
// Icarus Verilog 13.0 cannot compile a pattern as a port connection
// ("sorry", then a failed assertion).

typedef struct packed {
  logic [7:0] hi;
  logic [7:0] lo;
} pair_t;

module alp_mod(input pair_t in_p, input logic [7:0] in_a [3], output pair_t out_p,
               output logic [7:0] out_a [2]);
  assign out_p = '{in_p.lo + in_a[1], in_p.hi + in_a[1]};
  assign out_a = '{in_a[2], in_a[0]};
  initial #1 $display("module inputs: hi=%0d lo=%0d, in_a=%0d %0d %0d", in_p.hi, in_p.lo,
                      in_a[0], in_a[1], in_a[2]);
endmodule

interface alp_if(input pair_t in_p, input logic [7:0] in_a [3], output pair_t out_p,
                 output logic [7:0] out_a [2]);
  assign out_p = '{in_p.lo + in_a[1], in_p.hi + in_a[1]};
  assign out_a = '{in_a[2], in_a[0]};
  initial #2 $display("interface inputs: hi=%0d lo=%0d, in_a=%0d %0d %0d", in_p.hi, in_p.lo,
                      in_a[0], in_a[1], in_a[2]);
endinterface

program alp_prog(input pair_t in_p, input logic [7:0] in_a [3], output pair_t out_p,
                 output logic [7:0] out_a [2]);
  assign out_p = '{in_p.lo + in_a[1], in_p.hi + in_a[1]};
  assign out_a = '{in_a[2], in_a[0]};
  initial begin
    #3 $display("program inputs: hi=%0d lo=%0d, in_a=%0d %0d %0d", in_p.hi, in_p.lo,
                in_a[0], in_a[1], in_a[2]);
    #7;
  end
endprogram

module test_assignment_like_port_connections;
  int three = 3, four = 4;
  logic [7:0] mh, ml, ih, il, ph, pl;
  logic [7:0] ma, mb, ia, ib, pa, pb;

  alp_mod u_mod(.in_p('{three, four}), .in_a({8'd10, 8'd20, 8'd30}), .out_p('{mh, ml}),
                .out_a('{ma, mb}));
  alp_if u_if(.in_p('{four, three}), .in_a({8'd40, 8'd50, 8'd60}), .out_p('{ih, il}),
              .out_a('{ia, ib}));
  alp_prog u_prog('{three * 2, four * 2}, {8'd70, 8'd80, 8'd90}, '{ph, pl}, '{pa, pb});

  initial begin
    #4 $display("outputs: module %0d %0d, interface %0d %0d, program %0d %0d",
                mh, ml, ih, il, ph, pl);
    $display("array outputs: module %0d %0d, interface %0d %0d, program %0d %0d",
             ma, mb, ia, ib, pa, pb);
  end
endmodule
