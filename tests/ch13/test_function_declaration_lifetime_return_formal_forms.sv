/*
:name: test_function_declaration_lifetime_return_formal_forms
:description: function declarations with explicit static and automatic lifetimes, explicit, implicit and void return types, formals in parentheses or as declarations in the body, local declarations, statements and closing names (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_declaration_lifetime_return_formal_forms.expected
*/
// IEEE 1800-2023 13.4 (Syntax 13-2): a function declaration may give the
// lifetime static or automatic; its return type is an explicit data type,
// void, or the implicit form of only a signing and packed ranges, which means
// logic with them (a scalar logic when both are left out); the formals are in
// parentheses or declared with their directions in the body; the body has
// declarations and then statements; endfunction may repeat the name after a
// colon.
//
// count_static and count_auto have the same body, a local int n that is
// incremented and returned. With the static lifetime n keeps its value
// between calls (1, then 2); with the automatic lifetime it is a new
// variable at each call (1, then 1). narrow has the implicit return type
// signed [3:0]: 4'b1100 returns -4 and the result has 4 bits. is_odd has no
// return type at all, so it returns a 1-bit logic. note is void and is
// called as a statement. body_style declares its inputs a and b and a local
// t in the body (3, 4 give 34); ansi_style has the formals in parentheses and
// a local t (9, 4 give 5).

module test_function_declaration_lifetime_return_formal_forms;
  int last_note = 0;
  int s1, s2, a1, a2;

  function static int count_static();
    int n;
    n = n + 1;
    return n;
  endfunction : count_static

  function automatic int count_auto();
    int n;
    n = n + 1;
    return n;
  endfunction : count_auto

  function signed [3:0] narrow(input [3:0] x);
    narrow = x;
  endfunction

  function is_odd(input int v);
    return v[0];
  endfunction

  function void note(input int v);
    last_note = v;
  endfunction : note

  function int body_style;
    input int a;
    input int b;
    int t;
    t = a * 10;
    body_style = t + b;
  endfunction : body_style

  function int ansi_style(int a, int b);
    int t;
    t = a - b;
    return t;
  endfunction

  initial begin
    s1 = count_static();
    s2 = count_static();
    a1 = count_auto();
    a2 = count_auto();
    $display("static lifetime: %0d %0d", s1, s2);
    $display("automatic lifetime: %0d %0d", a1, a2);
    $display("implicit signed [3:0]: %0d bits=%0d", narrow(4'b1100), $bits(narrow(4'b1100)));
    $display("implicit scalar: %0d bits=%0d", is_odd(7), $bits(is_odd(7)));
    note(9);
    $display("void: last_note=%0d", last_note);
    $display("body formals: %0d", body_style(3, 4));
    $display("ansi formals: %0d", ansi_style(9, 4));
  end
endmodule
