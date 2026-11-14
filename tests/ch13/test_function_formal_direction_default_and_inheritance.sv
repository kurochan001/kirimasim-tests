/*
:name: test_function_formal_direction_default_and_inheritance
:description: function formals without a direction are inputs until a direction is given, and later formals without a direction take the last one, output, inout, ref or const ref (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_formal_direction_default_and_inheritance.expected
*/
// IEEE 1800-2023 13.4: a function formal with no direction is an input as
// long as no direction has been given; after a formal with a direction, the
// following formals without one have the same direction, and for ref the
// const qualifier is part of it. 13.4 also makes it illegal to call a
// function with a ref formal in a continuous assignment, unless the ref is
// const ref.
//
// f_in_out(int a, b, output int u, v): a and b are inputs, so the writes to
// them stay inside the call and i1, i2 keep 1 and 2; v is an output like u,
// so o2 receives 202 as o1 receives 101 (an input v would leave o2 at 66).
// f_inout(inout int c, d): d is inout, read and written back: c2 becomes 15.
// f_ref(ref int p, q): q refers to m_r, so q = q + 1 changes m_r at once
// and the function returns the new m_r, 21 (a copy would give 20).
// f_const_ref(const ref int p, q): q refers to m_q, so after the function
// sets m_q to 9 it reads 9 through q (an input copy would give 30).
// g_const_ref has the same formals and is called in a continuous
// assignment, which is legal only because q is const ref as well: y is
// 3 * 10 + 4 = 34, and 38 after m_b changes to 8.
//
// Icarus Verilog 13.0 does not parse const ref formals.

module test_function_formal_direction_default_and_inheritance;
  int m_x = 1, m_r = 20, m_q = 30, m_a = 3, m_b = 4;
  int i1, i2, o1, o2, c1, c2, r;
  int y;

  function automatic int f_in_out(int a, b, output int u, v);
    a = a + 100;
    b = b + 200;
    u = a;
    v = b;
    return a + b;
  endfunction

  function automatic void f_inout(inout int c, d);
    c = c + 1;
    d = d + 10;
  endfunction

  function automatic int f_ref(ref int p, q);
    q = q + 1;
    return m_r;
  endfunction

  function automatic int f_const_ref(const ref int p, q);
    m_q = 9;
    return q;
  endfunction

  function automatic int g_const_ref(const ref int p, q);
    return p * 10 + q;
  endfunction

  assign y = g_const_ref(m_a, m_b);

  initial begin
    i1 = 1; i2 = 2; o1 = 55; o2 = 66;
    r = f_in_out(i1, i2, o1, o2);
    $display("input default: i1=%0d i2=%0d r=%0d", i1, i2, r);
    $display("output inherited: o1=%0d o2=%0d", o1, o2);
    c1 = 5; c2 = 5;
    f_inout(c1, c2);
    $display("inout inherited: c1=%0d c2=%0d", c1, c2);
    r = f_ref(m_x, m_r);
    $display("ref inherited: r=%0d m_r=%0d", r, m_r);
    r = f_const_ref(m_x, m_q);
    $display("const ref inherited: r=%0d", r);
    #1;
    $display("const ref call in continuous assignment: y=%0d", y);
    m_b = 8;
    #1;
    $display("after m_b=8: y=%0d", y);
  end
endmodule
