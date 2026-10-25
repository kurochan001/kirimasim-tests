/*
:name: test_function_struct_return_member_or_scope
:description: Inside a function that returns a structure, a name starting with the function name selects a member of the return value, while outside the function, and as part of a longer hierarchical name, the function name stands for the function's scope (IEEE 1800-2023 Section 13.4.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_struct_return_member_or_scope.expected
*/
// IEEE 1800-2023 §13.4.1: when a function returns a structure, a
// hierarchical name used inside the function and beginning with the
// function name is a member of the return value. Used outside the function,
// or within a hierarchical name, the function name denotes the scope of the
// whole function.
//
// The static function mk returns pair_t {a, b} and also has a local
// variable named a. Inside it, mk.a and mk.b are the members of the result,
// and the plain a is the local variable (set to 100 * x). After mk(3) the
// result is a=3 b=4, while mk.a outside the function and the full name
// test_function_struct_return_member_or_scope.mk.a are the static local
// variable, 300.
//
// Simulator note: Verilator 5.052 rejects the full hierarchical name (it
// looks for a in the module instead of in the scope of mk); the other two
// lines match there.

module test_function_struct_return_member_or_scope;
  typedef struct packed {
    int a;
    int b;
  } pair_t;

  pair_t r;

  function pair_t mk(int x); // static, so its local a keeps its value
    int a;
    a = 100 * x;
    mk.a = x;
    mk.b = x + 1;
  endfunction

  initial begin
    r = mk(3);
    $display("result: a=%0d b=%0d", r.a, r.b);
    $display("mk.a outside the function: %0d", mk.a);
    $display("full hierarchical name: %0d", test_function_struct_return_member_or_scope.mk.a);
  end
endmodule
