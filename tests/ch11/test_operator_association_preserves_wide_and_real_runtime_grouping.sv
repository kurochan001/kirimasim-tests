/*
:name: test_operator_association_preserves_wide_and_real_runtime_grouping
:description: Unparenthesized arithmetic with wide integral and real operands follows the same left grouping as explicit parentheses
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.4.3 11.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_association_preserves_wide_and_real_runtime_grouping.expected
*/
module test_operator_association_preserves_wide_and_real_runtime_grouping;
  typedef logic [95:0] word_t;
  word_t payload, denom, factor, base, exponent, last_exp;
  real ratio, power, last_power;
  int sh_a, sh_b;

  initial begin
    #1;
    payload = 96'h0001000000000000000001a4;
    denom = 7;
    factor = 3;
    base = 3;
    exponent = 5;
    last_exp = 2;
    ratio = 0.5;
    power = 2.0;
    last_power = 3.0;
    sh_a = 40;
    sh_b = 2;

    $display("divmul=%h/%h/%h", word_t'(payload / denom * factor),
             word_t'((payload / denom) * factor), word_t'(payload / (denom * factor)));
    $display("modmul=%h/%h/%h", word_t'(payload % denom * factor),
             word_t'((payload % denom) * factor), word_t'(payload % (denom * factor)));
    $display("shift=%h/%h/%h", word_t'(payload >> sh_a << sh_b),
             word_t'((payload >> sh_a) << sh_b), word_t'(payload >> (sh_a << sh_b)));
    $display("integer power=%0d/%0d/%0d", base ** exponent ** last_exp,
             (base ** exponent) ** last_exp, base ** (exponent ** last_exp));
    $display("real power=%0.8f/%0.8f/%0.8f", ratio ** power ** last_power,
             (ratio ** power) ** last_power, ratio ** (power ** last_power));
    $display("near power=%0d/%0d/%0.4f/%0.4f", base * exponent ** last_exp,
             (base * exponent) ** last_exp, -ratio ** power, -(ratio ** power));
    $finish(0);
  end
endmodule
