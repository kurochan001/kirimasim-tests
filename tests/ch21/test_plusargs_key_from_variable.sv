/*
:name: test_plusargs_key_from_variable
:description: The plusarg string of $test$plusargs and $value$plusargs can be an integral variable, whose leading null characters are ignored (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +speed=40 +turbo
:expected_stdout: @test_plusargs_key_from_variable.expected
*/
// IEEE 1800-2023 §21.6: the string that a plusarg has to start with can be an
// integral variable read as a string, and leading nulls in the variable are
// ignored. The variables are wider than their text, so they start with null
// bytes; the calls still find +speed=40 and +turbo (:args:), and a key that no
// plusarg starts with gives 0.

module test_plusargs_key_from_variable;
  bit [8 * 12 - 1:0] value_key = "speed=%d";
  bit [8 * 8 - 1:0] flag_key = "turbo";
  bit [8 * 8 - 1:0] missing_key = "brake";
  int speed;
  initial begin
    if ($value$plusargs(value_key, speed)) $display("speed=%0d", speed);
    $display("turbo=%0d brake=%0d", $test$plusargs(flag_key) != 0,
             $test$plusargs(missing_key) != 0);
  end
endmodule
