/*
:name: test_subroutine_call_forms_arguments_scopes_and_selects
:description: Calls of tasks, functions, system functions, methods and scope randomize, with or without std::, with a package-scoped or hierarchical name, attribute instances after the name, omitted parentheses, positional arguments left empty, named arguments, and a select after the call, and constant function calls in parameters and a dimension (IEEE 1800-2023 Section 13.5.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.4 13.5.5 13.4.3 13.3 18.12 A.8.2 A.8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_call_forms_arguments_scopes_and_selects.expected
*/
// IEEE 1800-2023 A.8.2: a task or function call is a package-scoped or
// hierarchical name, any number of attribute instances and an optional
// parenthesized argument list; a subroutine call is such a call, a system
// call, a method call or a randomize call with an optional std::. An argument
// list is positional expressions, any of which may be left empty, followed by
// named arguments .name(expression), whose expression may be left out, or
// named arguments alone. A.8.4: a function call is a primary and may be
// followed by a select; a constant function call is a constant primary.
// §13.5.4: an empty or missing argument takes its default, and named
// arguments bind by name in any order. §13.5.5 and footnote 42: tasks, void
// functions and class methods may be called without parentheses when all
// arguments have defaults. §13.4.3: a constant function call has constant
// arguments and is evaluated at elaboration time, so it can give a parameter
// value and a dimension. §18.12: randomize(r) with a constraint, with or
// without std::, gives r the only value that satisfies it and returns 1.
//
// f3 adds its arguments, which default to 1, 20 and 300:
//   f3() 321, f3(5) 325, f3(5, , 7) 32, f3(, 2) 303, f3(1, .c(4)) 25,
//   f3(.c(9), .a(8)) 37 and f3(.b(), .a(2)) 322;
//   scp::twice(4) 8, sub.add10(5) 15, and f3 with two attribute instances
//   after its name and (1, 2, 3) is 6;
//   bump, vbump and bump() add 1, 10 and 1 to n_calls (12), and obj.get
//   without parentheses returns 7;
//   f3(0, 0, 1) + $clog2(16) + obj.get() + std::randomize(r) with {r == 5;}
//   is 1 + 4 + 7 + 1 = 13, and randomize(r2) with {r2 == 6;} returns 1;
//   code(3) is a3, so code(3)[3:0] is 3 and code(3)[5] is 1; the constant
//   calls give CS = code(5)[7:4] = a, CP = cf(3) = 9 and vec 4 bits wide.
//
// Icarus Verilog 13.0 rejects a select after a function call and a scope
// randomize call with a constraint as syntax errors.

package scp;
  function automatic int twice(int v);
    return 2 * v;
  endfunction
endpackage

module sc_sub;
  function automatic int add10(int v);
    return v + 10;
  endfunction
endmodule

module test_subroutine_call_forms_arguments_scopes_and_selects;
  class sc_c;
    int n = 7;
    function int get();
      return n;
    endfunction
  endclass

  function automatic int f3(int a = 1, int b = 20, int c = 300);
    return a + b + c;
  endfunction

  function automatic logic [7:0] code(int v);
    return 8'hA0 + v;
  endfunction

  function automatic int cf(int n);
    return n * n;
  endfunction

  localparam int CP = cf(3);
  localparam logic [3:0] CS = code(5)[7:4];

  sc_sub sub ();
  logic [cf(2) - 1:0] vec;
  int n_calls;
  int r, r2, ok2, sum;
  sc_c obj;

  task automatic bump();
    n_calls++;
  endtask

  function automatic void vbump();
    n_calls += 10;
  endfunction

  initial begin
    $display("args %0d %0d %0d %0d %0d %0d %0d", f3(), f3(5), f3(5, , 7), f3(, 2), f3(1, .c(4)),
             f3(.c(9), .a(8)), f3(.b(), .a(2)));
    $display("scopes %0d %0d %0d", scp::twice(4), sub.add10(5),
             f3 (* note *) (* again = 2 *) (1, 2, 3));
    bump;
    vbump;
    bump();
    obj = new;
    $display("noparen %0d %0d", n_calls, obj.get);
    sum = f3(0, 0, 1) + $clog2(16) + obj.get() + std::randomize(r) with {r == 5;};
    ok2 = randomize(r2) with {r2 == 6;};
    $display("kinds %0d %0d %0d %0d", sum, r, ok2, r2);
    $display("selects %h %b %h %0d %0d", code(3)[3:0], code(3)[5], CS, CP, $bits(vec));
  end
endmodule
