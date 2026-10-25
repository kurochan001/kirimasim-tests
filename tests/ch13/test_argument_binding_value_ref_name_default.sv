/*
:name: test_argument_binding_value_ref_name_default
:description: Subroutine arguments can be passed by value or by reference, bound by position or by name in any order, and left out so that their declared defaults are used, also with an empty position (IEEE 1800-2023 Section 13.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.5.1 13.5.2 13.5.3 13.5.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_argument_binding_value_ref_name_default.expected
*/
// IEEE 1800-2023 §13.5: arguments of a subroutine call can be passed by
// value (13.5.1) or by reference (13.5.2), bound by position or by name
// (13.5.4), and formals with defaults can be left out (13.5.3).
//
// combo(int a, ref int r, input int b = 3, input int c = 4) returns
// 1000*a + 100*b + 10*c + r, then adds 1 to its copy of a and sets r to
// r + 1. The calls bind by position with both defaults, with c's default,
// with an empty position for b, and by name in another order with b's
// default. After each call x, which is passed by reference, has gone up by
// one, and y, which is passed by value as a, is unchanged.

module test_argument_binding_value_ref_name_default;
  int x, y, res;

  function automatic int combo(int a, ref int r, input int b = 3, input int c = 4);
    combo = 1000 * a + 100 * b + 10 * c + r;
    a = a + 1;
    r = r + 1;
  endfunction

  initial begin
    x = 0;
    y = 1;
    res = combo(y, x);
    $display("combo(y, x):              %0d x=%0d y=%0d", res, x, y);
    res = combo(y, x, 5);
    $display("combo(y, x, 5):           %0d x=%0d y=%0d", res, x, y);
    res = combo(y, x, , 6);
    $display("combo(y, x, , 6):         %0d x=%0d y=%0d", res, x, y);
    res = combo(.c(8), .r(x), .a(2));
    $display("combo(.c(8), .r(x), .a(2)): %0d x=%0d y=%0d", res, x, y);
  end
endmodule
