/*
:name: test_std_randomize_call_forms
:description: std::randomize returns an int and accepts an optional parenthesized variable list of one or more names or none, an optional with constraint block, an attribute instance, and a call without parentheses, randomizing only the named variables and holding the constraints it is given (IEEE 1800-2023 Section G.5, 18.12, 18.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.12 G.5 18.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_randomize_call_forms.expected
*/
// IEEE 1800-2023 §G.5: randomize returns an int and its call form has optional
// parentheses around an optional variable list and an optional with constraint
// block, with room for an attribute instance after the keyword. §18.12: the
// scope randomize function behaves like the class method, so §18.11 applies:
// the names in the variable list are the random variables and every other
// variable of the scope is a state variable that the call leaves alone.
//
// The test calls std::randomize with no parentheses, with empty parentheses,
// with one variable, with two variables and a constraint between them, and
// with an attribute instance. It prints the size in bits of the result, which
// is 32 exactly when the result is an int, and checks that each constraint
// holds after the call, that the return is 1, and that a variable that the
// call does not name keeps its value.

module test_std_randomize_call_forms;
  int a;
  int b;

  initial begin
    int result;

    $display("result is 32 bits %0d",
             $bits(std::randomize(a)) == 32);

    a = 0;
    result = std::randomize;
    $display("no parentheses %0d", result);

    a = 0;
    result = std::randomize();
    $display("empty list %0d", result);

    a = 0;
    b = 1234;
    result = std::randomize(a) with { a > 10; a < 20; };
    $display("one variable in range %0d, other kept %0d",
             result == 1 && a > 10 && a < 20, b == 1234);

    a = 0;
    b = 0;
    result = std::randomize(a, b) with { a < b; };
    $display("two variables in order %0d", result == 1 && a < b);

    a = 0;
    result = std::randomize (* note = "scope call" *) (a) with { a == 3; };
    $display("attribute instance %0d", result == 1 && a == 3);
    $finish;
  end
endmodule
