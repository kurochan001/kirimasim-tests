/*
:name: test_illegal_constant_function_calls_nonconstant_function
:description: a constant function cannot call a function that is not a constant function (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f, called in the initial value of the localparam P, calls the function g, which reads a module variable
:expected_stderr_regex: test_illegal_constant_function_calls_nonconstant_function\.sv:(33|50|54):
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not call functions other
// than constant functions, except built-in methods of its local variables,
// which include its implicit result variable (13.4.1). g reads the module
// variable base, so it is not a constant function, and f, which calls it, is
// not one either. h calls the constant function k and the built-in methods
// push_back() and size() of its local queue, and tag calls putc() and substr()
// of its implicit variable tag, so the calls of h and tag in the initial values
// of Q and S are legal.
// A function that breaks one of the constraints of a constant function is not
// one, and its call in the initial value of a localparam, which requires a
// constant expression (11.2.1), is then illegal; a tool can report the error at
// the call or at the line that breaks the constraint.
// Icarus Verilog 13.0 and Verilator 5.052 also fail on the legal call of h,
// whose queue methods they cannot evaluate at elaboration time, so their
// rejections do not count.

module test_illegal_constant_function_calls_nonconstant_function;
  int base = 10;
  function int g(input int a);
    return a + base;
  endfunction
  function int k(input int a);
    return a * 3;
  endfunction
  function int h(input int a);
    int q[$];
    q.push_back(k(a));
    q.push_back(a);
    return q.size() + q[0];
  endfunction
  function string tag(input int a);
    tag = "abc";
    tag.putc(0, "x");
    return tag.substr(0, a);
  endfunction
  function int f(input int a);
    return a + g(1);
  endfunction
  localparam int Q = h(2);
  localparam string S = tag(1);
  localparam int P = f(1);   // illegal
  initial $display("%0d %0d %s", P, Q, S);
endmodule
