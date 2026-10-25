/*
:name: test_data_type_keyword_forms
:description: Data types written with keywords: every integer atom and vector type with both signs, the three non-integer types, string, chandle and event, an enum with an atom, a vector and a typedef base and with name ranges, a packed signed struct, a struct with a rand member, packed arrays of structs and unions, a soft union, an implicit data type, and and a net of a built-in net type (IEEE 1800-2023 Sections 6.11 to 6.19 and 7.2, 7.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 6.12 6.14 6.16 6.17 6.19 7.2 7.3 A.2.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_data_type_keyword_forms.expected
*/
// IEEE 1800-2023 A.2.2.1: a data_type is an integer vector type with an
// optional signing and packed dimensions, an integer atom type with an
// optional signing, a non-integer type, a struct or union with optional
// packed and signing and repeated packed dimensions, an enum with an
// optional base type and nonempty name list, string, chandle, event, or a
// type identifier with packed dimensions. An enum name may carry an integral
// range and an initializer, a struct or union member may carry attributes, a
// random qualifier and a void type, and an implicit data type is an optional
// signing and packed dimensions alone.
//   - the atom, vector, sign, real, string, chandle and event values are
//     printed with their sizes and values,
//   - ONE[2] gives ONE0 and ONE1, TEN[2:4] = 10 gives TEN2, TEN3 and TEN4
//     with 10, 11 and 12,
//   - sp is a packed signed struct, sp2 a packed array of two structs, s2 an
//     unpacked struct with named members, s3 an unpacked struct with a rand
//     member, us a soft union and up a packed union,
//   - imp and imp2 are variables with an implicit data type,
//
// Icarus Verilog 13.0 does not support unpacked structures. Verilator 5.052
// does not accept every declaration here.

typedef enum bit [1:0] {RED = 2'd0, GREEN = 2'd1, BLUE = 2'd2} color_t;
typedef enum {ONE[2], TEN[2:4] = 10} range_t;
typedef enum logic [2:0] {S0 = 3'd0, S1 = 3'd7} state_t;
typedef logic [1:0] two_t;
typedef enum two_t {T0 = 2'd0, T1 = 2'd3} tbase_t;

typedef struct packed signed {logic [1:0] hi; logic lo;} sp_t;
typedef struct packed {logic [1:0] a; logic [1:0] b;} [1:0] sp2_t;
typedef struct {int x; byte y;} s2_t;
typedef struct {rand int r;} s3_t;
typedef union soft packed {logic [3:0] a; logic [3:0] b;} us_t;
typedef union packed {logic [3:0] a; logic [3:0] b;} up_t;

module test_data_type_keyword_forms;
  byte b8 = 8'shFE;
  shortint s16 = 16'sh8000;
  int i32 = -3;
  longint l64 = 64'sd5;
  integer i = 7;
  time t = 6;
  bit vb = 1'b1;
  logic vl = 1'b0;
  reg vr = 1'b1;
  byte signed bs = -1;
  byte unsigned bu = 8'hFF;
  logic signed [3:0] ls = -2;
  logic unsigned [3:0] lu = 4'hE;
  logic [1:0][1:0] pd = 4'b1010;
  bit signed [3:0][1:0] ps = -1;
  var [3:0] imp = 4'hA;
  var signed [3:0] imp2 = -2;
  shortreal sr = 1.5;
  real rr = 2.25;
  realtime rt = 3.5;
  string str = "abc";
  chandle ch;
  event ev;
  color_t col = GREEN;
  range_t rng = TEN3;
  state_t st = S1;
  tbase_t tb = T1;
  sp_t sp = '{hi: 2'b10, lo: 1'b1};
  sp2_t sp2 = 8'b1010_0101;
  s2_t s2 = '{x: 3, y: 4};
  s3_t s3 = '{r: 5};
  us_t us = 4'h5;
  up_t up = 4'h6;
  wire [3:0] wn;

  assign wn = 4'h7;

  initial begin
    -> ev;
    $display("atom: b8=%0d s16=%0d i32=%0d l64=%0d i=%0d t=%0d",
             b8, s16, i32, l64, i, t);
    $display("vector: vb=%b vl=%b vr=%b bs=%0d bu=%0d ls=%0d lu=%0d",
             vb, vl, vr, bs, bu, ls, lu);
    $display("packed: pd=%b ps=%b imp=%h imp2=%0d sp=%b/%b sp2=%b",
             pd, ps, imp, imp2, sp.hi, sp.lo, sp2);
    $display("real: sr=%0.1f rr=%0.2f rt=%0.1f", sr, rr, rt);
    $display("string: len=%0d s=%s", str.len(), str);
    $display("chandle null=%0d event=%0d", ch == null, ev.triggered);
    $display("enum: col=%0d rng=%0d st=%0d tb=%0d one=%0d/%0d ten=%0d/%0d/%0d",
             col, rng, st, tb, ONE0, ONE1, TEN2, TEN3, TEN4);
    $display("struct: s2=%0d s3=%0d", s2.x + s2.y, s3.r);
    $display("union: soft=%b packed=%b", us.a, up.a);
    #1 $display("net: wn=%h", wn);
  end
endmodule
