/*
:name: test_nonresistive_switch_strength
:description: nmos, cmos and tran pass the strength of their input, except that supply strength becomes strong (IEEE 1800-2023 Section 28.13)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.13 28.12.1 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nonresistive_switch_strength.expected
*/
// IEEE 1800-2023 §28.13: nmos, pmos and cmos switches pass the strength of
// their data input to their output, and tran, tranif0 and tranif1 keep the
// strength across their terminals, except that a supply strength becomes
// strong. So a supply 1 through an nmos is a strong 1: it ties with a strong 0
// and beats a pull 0 (28.12.1), while a pull 1 passes as a pull 1.

module test_nonresistive_switch_strength;
  wire s1; assign (supply0, supply1) s1 = 1'b1;
  wire p1; assign (pull0, pull1) p1 = 1'b1;
  wire a; nmos g_a(a, s1, 1'b1);
  wire b; nmos g_b(b, p1, 1'b1);
  wire c; cmos g_c(c, s1, 1'b1, 1'b0);
  wire d; tran g_d(s1, d);
  wire e; nmos g_e(e, s1, 1'b1); assign e = 1'b0;
  wire f; nmos g_f(f, s1, 1'b1); assign (pull0, pull1) f = 1'b0;

  initial begin
    #1;
    $display("nmos supply=%v nmos pull=%v cmos supply=%v tran supply=%v", a, b, c, d);
    $display("vs strong0=%v vs pull0=%v", e, f);
  end
endmodule
