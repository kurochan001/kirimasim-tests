/*
:name: test_enum_explicit_cast_and_failed_dynamic_cast
:description: An explicit enum cast permits an integral value and a failed dynamic cast leaves the destination unchanged (IEEE 1800-2023 Section 6.22.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_explicit_cast_and_failed_dynamic_cast.expected
*/
// IEEE 1800-2023 6.22.4: Integral to enum conversion needs an explicit cast;
// dynamic cast checks membership and must not overwrite a destination on
// failure.
// Oracle checks: Icarus Verilog 13.0 does not reproduce the clause-derived
// output.

module test_enum_explicit_cast_and_failed_dynamic_cast;
  typedef enum int { LOW = 3, HIGH = 8 } level_t;
  level_t level;
  int ok;
  initial begin
    level = level_t'(8);
    ok = $cast(level, 99);
    $display("failed=%0d retained=%0d", ok, level);
    ok = $cast(level, 3);
    $display("success=%0d value=%0d", ok, level);
  end
endmodule
