/*
:name: test_illegal_display_undefined_format_specifier
:description: a format specifier that neither Table 21-1 nor Table 21-2 defines is an error (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.2.1.1 21.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the string literal of the last $display contains %y, which is not a defined format specifier
:expected_stderr_regex: test_illegal_display_undefined_format_specifier\.sv:30:
*/
// IEEE 1800-2023 §21.2.1.1: Table 21-1 lists the format specifications of the
// display tasks (h, x, d, o, b, c, l, v, m, p, s, t, u and z, in either
// case), and Table 21-2 adds the real formats e, f and g. A string literal
// that contains a specifier that is not defined is an error. The first
// $display statements use only defined specifiers, in lowercase and in
// uppercase, and are legal. The last one uses %y, which no table defines.
// Icarus Verilog 13.0 accepts the design and only warns when the task runs.

module test_illegal_display_undefined_format_specifier;
  int a = 3;
  real r = 1.5;

  initial begin
    $display("%m %l %%");
    $display("%h %X %d %O %b %C", a, a, a, a, a, a);
    $display("%e %F %g %s %P", r, r, r, "s", a);
    $display("a=%y", a);   // illegal: %y is not a format specifier
  end
endmodule
