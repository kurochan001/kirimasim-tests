/*
:name: test_subroutine_input_expressions_and_call_forms
:description: An input actual may be any compatible expression, and calls accept positional, named and empty actuals plus system, method and void-cast call forms (IEEE 1800-2023 Section 13.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_input_expressions_and_call_forms.expected
*/
// IEEE 1800-2023 §13.5: the expression passed to an input formal can be any
// expression, and the order in which the actual expressions are evaluated is
// undefined, so the test never depends on that order. The calls use an
// arithmetic expression and an array element, a nested function call, a
// system function call, a built-in string method, a void cast of a function
// call used as a statement, named actuals in another order, and an empty
// position that leaves the default of the formal in place.

module test_subroutine_input_expressions_and_call_forms;
  string s;
  int arr[3];

  function automatic int add(input int a, b);
    return a + b;
  endfunction

  function automatic int dflt(input int a = 1, b = 2, c = 3);
    return 100 * a + 10 * b + c;
  endfunction

  function automatic void show(input int x);
    $display("show=%0d", x);
  endfunction

  initial begin
    s = "hello";
    arr[0] = 1;
    arr[1] = 2;
    arr[2] = 3;
    $display("expr=%0d", add(2 + 3, arr[1] * 4));
    $display("nest=%0d", add(add(1, 2), 4));
    $display("sys=%0d", add($clog2(8), 1));
    $display("method=%0d", s.len());
    show(3 * 4);
    void'(add(1, 1));
    $display("named=%0d", add(.b(2), .a(5)));
    $display("dflt=%0d", dflt(4, , 6));
    $display("dflt2=%0d", dflt(.c(9)));
  end
endmodule
