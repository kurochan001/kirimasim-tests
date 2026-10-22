/*
:name: test_pattern_format_enum_string_null
:description: Pattern formatting uses enum names quoted strings and the fixed null spelling (IEEE 1800-2023 Section 21.2.1.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pattern_format_enum_string_null.expected
*/
// IEEE 1800-2023 21.2.1.6: The singular element rules require symbolic enum
// names and quoted strings, while a null class handle has a fixed spelling
// rather than an implementation-dependent object address.
// Oracle checks: Icarus Verilog 13.0 does not reproduce the clause-derived
// output.

module test_pattern_format_enum_string_null;
  typedef enum int { STOP = 3, RUN = 9 } state_t;
  class item; endclass
  item absent;
  state_t state_value = RUN;
  string text_value = "hello";
  initial begin
    $display("enum=%p string=%p handle=%p", state_value, text_value, absent);
  end
endmodule
