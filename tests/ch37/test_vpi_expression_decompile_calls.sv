/*
:name: test_vpi_expression_decompile_calls
:description: vpiDecompile gives an equivalent expression with one space between operands and operators and parentheses only where precedence needs them; a function call, a method function call and a let expression are expressions whose vpiSize is the width of their result (IEEE 1800-2023 Section 37.59)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.59 37.42 37.57 11.3.2 11.12 13.4 8.10 37.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_expression_decompile_calls.c
:expected_stdout: @test_vpi_expression_decompile_calls.expected
*/
// IEEE 1800-2023 §37.59: every expression has vpiDecompile, a string with an
// expression equivalent to the one in the source, in which parentheses are
// added only to preserve precedence, each operand and operator are separated
// by one space, and parentheses add no white space (detail 2). The VPI model
// of an operation has no parentheses: precedence and left associativity
// (11.3.2) give its shape, so parentheses that the shape needs come back and
// those that it does not need are left out. Function calls, method function
// calls and let expressions are in the expression group, so they have its
// properties, such as vpiSize, the width of the expression: the 6-bit result
// of the function six (13.4), the 10-bit result of the class method ten
// (8.10), and the let pick, whose body selects bits 6 to 2 of its argument
// (11.12), so it is 5 bits wide.
//
// The task exprs is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). Each assignment has its own target, by which the lines are
// sorted; for the targets d1 to d7 the application prints vpiDecompile of the
// right-hand side between quotes, for the others the kind of the right-hand
// side and its vpiSize.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the expression types, and a
// run with Verilator 5.052 gives no statements of the task.

module test_vpi_expression_decompile_calls;
  class box;
    function logic [9:0] ten();
      return 10'd1;
    endfunction
  endclass

  function logic [5:0] six(input logic [7:0] x);
    return x[5:0];
  endfunction

  let pick(x) = x[6:2];

  int a, b, c, d1, d2, d3, d4, d5, d6, d7;
  logic [7:0] b8;
  logic [5:0] f6;
  logic [9:0] m10;
  logic [4:0] l5;
  box obj;

  task exprs;
    d1 = a+b*c;
    d2 = (a+b)*c;
    d3 = a-(b-c);
    d4 = (a*b)+c;
    d5 = a&&(b||c);
    d6 = (a<<b)<<c;
    d7 = a<<(b<<c);
    f6 = six(b8);
    m10 = obj.ten();
    l5 = pick(b8);
  endtask
endmodule
