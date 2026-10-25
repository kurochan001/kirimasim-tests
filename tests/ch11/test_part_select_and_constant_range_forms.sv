/*
:name: test_part_select_and_constant_range_forms
:description: A part select with a constant range or an indexed range with +: or -: gives the bits it addresses, with a constant or a run-time base and a constant width; a select of a parameter, a bit select of a struct member and a member select of a nested packed struct give their values (IEEE 1800-2023 Sections 11.5.1 and 11.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 11.5 11.2.1 A.8.3 A.8.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_part_select_and_constant_range_forms.expected
*/
// IEEE 1800-2023 A.8.3: a constant range expression is a constant expression
// or a constant part-select range; a constant part-select range is a constant
// range low:high or a constant indexed range with +: or -: and a constant
// width. A part-select range has a constant range or an indexed range whose
// base is an expression and whose width is a constant. A genvar expression is
// a constant expression. A.8.4: a select is a member name with bit selects,
// a final member name, bit selects and an optional part-select range.
//
// §11.5.1: in vect[msb:lsb] the first index is the more significant one, an
// ascending vector has its left index the most significant, and an indexed
// part-select takes its width from a positive constant and its base from any
// expression. With V = 16'hA5C3 and the ascending UP = 16'hA5C3:
//   V[7:4] = c, UP[4:7] = 5, V[8 +: 4] = 5, V[11 -: 4] = 5,
//   V[4 +: 4] = c and V[7:4] = c, the last two with parameters as indices;
//   v[7:4] = c, v[8 +: 4] = 5, v[11 -: 4] = 5, v[6 +: 4] = 7,
//   v[6 -: 4] = 8 and v[6] = 1 with the run-time variable v;
//   v[15:12] = a and mem[1] = 22;
//   bx.p.hi = a, bx.p.lo[3:2] = 1, bx.p.hi[2] = 0 and bx.tag = 2, with the
//   nested packed structs pair_t and box_t;
//   mem[1][3:0] = 2 before the write, then mem[2] = 77 and mem[0] = 11;
//   the loop generate's condition gi < W is a genvar expression, a constant
//   expression with the parameter W, and its four blocks give 4, 5, 6, 7.

module test_part_select_and_constant_range_forms;
  logic [15:0] v = 16'hA5C3;
  logic [7:0] mem [0:3] = '{8'h11, 8'h22, 8'h33, 8'h44};
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;
  typedef struct packed { pair_t p; logic [1:0] tag; } box_t;
  box_t bx;
  int idx = 6;

  localparam [15:0] V = 16'hA5C3;
  localparam [0:15] UP = 16'hA5C3;
  localparam int LO = 4, HI = 7, W = 4;
  localparam [3:0] CR = V[7:4];
  localparam [3:0] CA = UP[4:7];
  localparam [3:0] CI1 = V[8 +: 4];
  localparam [3:0] CI2 = V[11 -: 4];
  localparam [3:0] CP = V[LO +: W];
  localparam [3:0] CS = V[HI : LO];

  logic [3:0] a, b, c, d, e, f;

  for (genvar gi = 0; gi < W; gi++) begin : gps
    wire [3:0] gw;
    assign gw = gi + LO;
  end

  initial begin
    bx.p.hi = 4'hA;
    bx.p.lo = 4'h5;
    bx.tag = 2'b10;
    a = v[7:4];
    b = v[8 +: 4];
    c = v[11 -: 4];
    d = v[idx +: 4];
    e = v[idx -: 4];
    f = v[idx];
    $display("const %h %h %h %h %h %h", CR, CA, CI1, CI2, CP, CS);
    $display("var %h %h %h %h %h %h", a, b, c, d, e, f);
    $display("sel %h %h %h %h", v[15:12], mem[1], bx.p.hi, bx.p.lo[3:2]);
    $display("sel2 %h %h %h", bx.p.hi[2], bx.tag, mem[idx - 5][3:0]);
    $display("gen %h %h %h %h", gps[0].gw, gps[1].gw, gps[2].gw, gps[3].gw);
    mem[2] = 8'h77;
    $display("mem %h %h %h", mem[2], mem[idx - 4], mem[0]);
  end
endmodule
