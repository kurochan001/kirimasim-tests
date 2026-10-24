/*
:name: test_vpi_systf_task_function_places
:description: A user-defined system task is called where a void function can be, in a function, as a statement and in a final procedure, and writes its argument; a user-defined system function is called in expressions, writes its argument and returns a value as wide as its sizetf says (IEEE 1800-2023 Section 36.5)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.5 36.4 36.8.1 13.4 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_task_function_places.c
:expected_stdout: @test_vpi_systf_task_function_places.expected
*/
// IEEE 1800-2023 §36.5: a user-defined system task can be used where a void
// function can (13.4) and can read and modify its arguments, without a
// result; a user-defined system function can be used where a function can,
// can read and modify its arguments, and returns a value whose width its
// sizetf gives (36.8.1). $vt_incr adds 1 to its argument (36.4, 38.34): it
// is called twice inside the function bump_twice, as a statement, and in a
// final procedure. $vt_take, a vpiSizedFunc whose sizetf gives 12, returns
// its argument plus 12'hf00 and adds 100 to the argument; its result printed
// with %h has 3 digits, and it is also called inside a larger expression.
// Icarus Verilog 13.0, which needs the types of user-defined system
// functions when it compiles (in a .sft file), gives $vt_take 32 bits; calls
// of user-defined system tasks are not supported in Verilator 5.052.

module test_vpi_systf_task_function_places;
  int a = 5, b = 1;

  function automatic int bump_twice(input int x);
    int y;
    y = x;
    $vt_incr(y);
    $vt_incr(y);
    return y;
  endfunction

  initial begin
    $display("task in a function: %0d", bump_twice(10));
    $vt_incr(a);
    $display("task as a statement: a=%0d", a);
    $display("function result: %h", $vt_take(b));
    $display("argument after the call: b=%0d", b);
    $display("function in an expression: %0d", $vt_take(b) + 1);
    $display("argument after the call: b=%0d", b);
  end

  final begin
    $vt_incr(a);
    $display("task in a final procedure: a=%0d", a);
  end
endmodule
