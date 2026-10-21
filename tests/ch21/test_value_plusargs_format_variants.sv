/*
:name: test_value_plusargs_format_variants
:description: $value$plusargs accepts its format specifiers in uppercase, as %x and with a leading 0 (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +alpha=255 +beta=ff +gamma=12 +delta=0101
:expected_stdout: @test_value_plusargs_format_variants.expected
*/
// IEEE 1800-2023 §21.6: the format of $value$plusargs is one of the formats of
// $display listed there, written in lowercase or uppercase and also in the
// leading 0 form, and %x is the same as %h. The runner passes the plusargs
// (:args:); each call finds its plusarg and converts the rest of it.

module test_value_plusargs_format_variants;
  int a, b, c, d;
  initial begin
    if ($value$plusargs("alpha=%D", a)) $display("alpha=%0d", a);
    if ($value$plusargs("beta=%X", b)) $display("beta=%0d", b);
    if ($value$plusargs("gamma=%0d", c)) $display("gamma=%0d", c);
    if ($value$plusargs("delta=%B", d)) $display("delta=%0d", d);
  end
endmodule
