/*
:name: test_vpi_cast_pattern_constants
:description: A cast is a unary vpiCastOp whose typespec is the target type; an assignment pattern lists its operands in positional order, also for member, index and default keys and nested patterns; a replicated pattern gives the multiplier first; a type-prefixed pattern and a simple expression have a typespec; vpiConstType tells the kind of each constant and vpiSize gives the width of casts and constants (IEEE 1800-2023 Section 37.59)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.59 6.24.1 10.9.1 10.9.2 5.7.1 5.7.2 5.9 37.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_cast_pattern_constants.c
:expected_stdout: @test_vpi_cast_pattern_constants.expected
*/
// IEEE 1800-2023 §37.59: a cast (6.24.1) is an operation with vpiOpType
// vpiCastOp and a single operand, the expression cast, and its typespec is
// the type cast to (detail 3). The operands of a vpiAssignmentPatternOp are
// the expressions of the equivalent positional pattern, with nested patterns
// kept (detail 6; keys of 10.9.1 and 10.9.2: '{c: 3, default: 7} for a struct
// of a, b, c is '{7, 7, 3}). A vpiMultiAssignmentPatternOp gives its
// multiplier first and then the expressions inside (detail 7). The typespec
// relation always exists for casts, simple expressions and patterns prefixed
// by a type name (detail 5). vpiConstType gives the kind of a constant, from
// sv_vpi_user.h and vpi_user.h (Annex K, Annex M): decimal, binary, octal and
// hexadecimal integers (5.7.1), a real (5.7.2), a string literal (5.9) and
// null. vpiSize is the width of an expression: 32 for a cast to int, 12 for a
// cast to the 12-bit word_t, 8 for an 8-bit literal and 16 for a string
// literal of two characters (5.9).
//
// The task exprs is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). Each assignment has its own target, by which the lines are
// sorted; the application prints the right-hand side. A typespec is printed
// by its kind, and by its name only where the type is a typedef.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the operation types, and a run
// with Verilator 5.052 gives no statements of the task.

module test_vpi_cast_pattern_constants;
  typedef logic [11:0] word_t;
  typedef struct { int a; int b; int c; } trip_t;
  typedef struct { int a; int q [0:1]; } nest_t;

  class node;
  endclass

  logic [7:0] b8, s8;
  int y, i1, arr3 [0:2];
  word_t w1;
  trip_t t1, t2;
  nest_t n1;
  logic [7:0] k_dec, k_bin, k_oct, k_hex;
  real k_real;
  logic [15:0] k_str;
  node k_null;

  task exprs;
    i1 = int'(b8);
    w1 = word_t'(b8);
    s8 = b8;
    t1 = '{c: 3, default: 7};
    n1 = '{q: '{1: 5, default: 4}, a: 2};
    t2 = trip_t'{1, 2, 3};
    arr3 = '{3{y}};
    k_dec = 8'd5;
    k_bin = 8'b1010_0101;
    k_oct = 8'o17;
    k_hex = 8'hA5;
    k_real = 2.5;
    k_str = "hi";
    k_null = null;
  endtask
endmodule
