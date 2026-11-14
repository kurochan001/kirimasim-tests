/*
:name: test_operand_categories_every_kind
:description: every kind of operand listed for expressions is used and printed: literals, parameters, localparams and specparams and their selects, nets, variables and their selects, structures, unions (packed, unpacked and tagged), their members and selects, packed and unpacked arrays with their elements, selects and slices, and calls of functions, system functions and methods (IEEE 1800-2023 Section 11.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operand_categories_every_kind.expected
*/
// IEEE 1800-2023 §11.2: an operand can be a literal number (real ones too),
// a string literal, a parameter (local and specify parameters included) or a
// bit- or part-select of one, a net or variable or a select of one, a packed
// or unpacked structure or a member of one, a select of a packed structure,
// a packed, unpacked or tagged union or a member of one, a select of a
// packed union, a packed or unpacked array, a bit-select, part-select,
// element or slice of a packed array, an element, a select of an element or
// a slice of an unpacked array, and a call of a user function, a system
// function or a method that returns one of these.
// Each line uses operands of one or two of these kinds in expressions and
// prints the result, so an operand read wrongly, or a select of the wrong
// bits, changes the line. Whole unpacked structures, unions and arrays are
// copied by assignment; the copied structure and array are compared with ==
// (§11.2.2), and members of the copied unions are read.
// The values are written in hexadecimal where they are bit patterns.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports
// tagged unions, so the expected output follows the standard.

class box_c;
  int val = 21;
  function int twice();
    return val * 2;
  endfunction
endclass

module test_operand_categories_every_kind;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } nib_t;
  typedef struct {
    int a;
    byte b;
  } rec_t;
  typedef union packed {
    logic [7:0] whole;
    nib_t parts;
  } pu_t;
  typedef union {
    int i;
    logic [31:0] v;
  } uu_t;
  typedef union tagged {
    void None;
    int Some;
  } opt_t;
  typedef logic [7:0] row_t [0:3];

  parameter logic [7:0] P = 8'h5a;
  localparam logic [7:0] LP = 8'hc3;
  specparam [7:0] SP = 8'h96;

  wire [7:0] w = 8'h3c;
  logic [7:0] v = 8'ha5;
  nib_t ps = '{hi: 4'h7, lo: 4'h2};
  rec_t us = '{a: 10, b: 8'sd3};
  rec_t uc;
  pu_t pu;
  uu_t uu, uu2;
  opt_t tu, tu2;
  logic [3:0][7:0] pa = 32'h11223344;
  row_t ua = '{8'h01, 8'h23, 8'h45, 8'h67};
  row_t uc2;
  logic [7:0] ub [0:1];
  box_c bx = new;
  string s = "hi";
  int q[$] = '{1, 2, 3};

  function automatic nib_t swap(nib_t n);
    return '{hi: n.lo, lo: n.hi};
  endfunction

  initial begin
    pu.whole = 8'h9e;
    uu.i = 7;
    tu = tagged Some (40);
    #1;
    $display("literals: %0d %.2f %0d %0d", 12 + 3, 1.25 * 2, "A" + 0, "ab" == 16'h6162);
    $display("parameters: %h %h %h  selects: %h %b %b %h", P, LP, SP, P[3:0], LP[7], SP[1:0],
             SP[7:4]);
    $display("net: %h %h %b  variable: %h %h %b", w, w[7:4], w[0], v, v[3:0], v[7]);
    uc = us;
    $display("structures: %h %0d %0d  members: %0d  selects: %h %b", ps, uc == us, uc.a + uc.b,
             us.a + ps.lo, ps[7:4], ps[0]);
    uu2 = uu;
    tu2 = tu;
    $display("unions: %h %0d %0d  members: %h %0d %0d  selects: %h %b", pu, uu2.i + 1,
             tu2.Some + 2, pu.parts.hi, uu.i, tu.Some, pu[3:0], pu[7]);
    $display("packed array: %h  element: %h  slice: %h  part: %h  bit: %b", pa, pa[3], pa[2:1],
             pa[0][3:0], pa[1][4]);
    uc2 = ua;
    ub = ua[1:2];
    $display("unpacked array: %0d  element: %h  part: %h  bit: %b  slice: %h %h", uc2 == ua,
             ua[2], ua[3][7:4], ua[1][0], ub[0], ub[1]);
    $display("calls: %h %0d %0d %0d %0d %0d", swap(ps), $clog2(256), bx.twice(), s.len(),
             q.size(), q.sum());
  end
endmodule
