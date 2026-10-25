/*
:name: test_syntax_pullup_pulldown_strengths
:description: pullup and pulldown declared without a strength, with only the strength of their value, and with both strengths in either order, each with one or more named or unnamed instances (IEEE 1800-2023 Section 28.10)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.10 28.3.2 A.3.1 A.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_pullup_pulldown_strengths.expected
*/
// IEEE 1800-2023 §28.10, A.3.1, A.3.2: a pullup or pulldown declaration has
// an optional strength and one or more instances separated by commas; each
// instance has an optional name and one terminal. The strength of a pullup
// is (strength1), (strength0, strength1) or (strength1, strength0), and that
// of a pulldown (strength0) or one of the two pairs. A pullup drives 1 and a
// pulldown 0, with pull strength by default; the strength of the value
// driven is the one given, and the other strength of a pair is ignored
// (28.10, 28.3.2).
//
// Every form is used, the ignored strength of each pair differs from the
// used one, and each net is printed with %v.

module test_syntax_pullup_pulldown_strengths;
  wire u0, u1, u2, u3, u4, d0, d1, d2, d3, d4;

  pullup g_u0 (u0), (u1);
  pullup (strong1) g_u2 (u2);
  pullup (strong0, weak1) (u3);
  pullup (supply1, weak0) g_u4 (u4);
  pulldown (d0), g_d1 (d1);
  pulldown (strong0) (d2);
  pulldown (weak0, strong1) g_d3 (d3);
  pulldown (pull1, supply0) g_d4 (d4);

  initial begin
    #1;
    $display("pullup: %v %v %v %v %v", u0, u1, u2, u3, u4);
    $display("pulldown: %v %v %v %v %v", d0, d1, d2, d3, d4);
  end
endmodule
