/*
:name: test_return_overrides_function_name_value
:description: A return statement with an expression gives the result of a function even after a value was assigned to the function name, while a call that ends without a return gives the value of the name (IEEE 1800-2023 Section 13.4.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_return_overrides_function_name_value.expected
*/
// IEEE 1800-2023 §13.4.1: a function has an implicit variable named after it,
// and its result can be given by assigning that variable or by a return
// statement; the return statement overrides any value assigned to the name.
//
//   over(3):      over = 30, then return 3 + 1, so the result is 4, not 30;
//   pick(7):      pick = 100, then the return in the if branch gives 7;
//   pick(-1):     pick = 100 and no return is executed, so the result is the
//                 value of the name, 100 (the control for pick(7));
//   from_name(5): from_name = 10, then return from_name + 1 reads the name
//                 and gives 11, not 10.
// An implementation that kept the value of the name once it was assigned
// would print 30, 100 and 10 for the calls that execute a return.

module test_return_overrides_function_name_value;
  function int over(input int x);
    over = x * 10;
    return x + 1;
  endfunction

  function int pick(input int x);
    pick = 100;
    if (x > 0) return x;
  endfunction

  function int from_name(input int x);
    from_name = x * 2;
    return from_name + 1;
  endfunction

  initial begin
    $display("over(3)=%0d", over(3));
    $display("pick(7)=%0d", pick(7));
    $display("pick(-1)=%0d", pick(-1));
    $display("from_name(5)=%0d", from_name(5));
  end
endmodule
