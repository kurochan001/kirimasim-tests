/*
:name: test_string_atoreal_scan_rules
:description: atoreal() parses the longest leading real constant, stops at the first character that does not fit the syntax or at the end, and returns 0 when it meets no digit (IEEE 1800-2023 Section 6.16.10)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.10 5.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atoreal_scan_rules.expected
*/
// IEEE 1800-2023 §6.16.10: atoreal() parses a real constant at the start of
// the string and stops at the first character that does not fit its syntax,
// or at the end; with no digit it returns 0. A real constant (§5.7.2) has
// digits with underscores, an optional fraction with digits on both sides of
// the point, and an optional exponent e or E with an optional sign. So the
// scan stops at the second point of "12.5.6" and at the x of "23E1x", and a
// string that starts with a point, a letter or a space has no leading digit
// and gives 0.
// Icarus Verilog 13.0 returns 0.0 for every string of the array. Verilator
// 5.052 stops at the underscore of "1_0.2_5" (1.0), and like C strtod skips
// the leading space and reads ".5" (1.5 and 0.5); the standard ignores the
// underscores of a real constant and needs a digit before the point.

module test_string_atoreal_scan_rules;
  string s[12] = '{"2.5e3xyz", "1_0.2_5", "3.75", "12.5.6", "1.5E-2", "6e+1", "23E1x",
                   "abc", "", ".5", "e5", " 1.5"};

  initial begin
    foreach (s[i]) $display("atoreal(\"%s\")=%0.3f", s[i], s[i].atoreal());
  end
endmodule
