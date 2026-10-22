/*
:name: test_string_binary_octal_round_trip
:description: Binary and octal conversion methods replace an existing string and round trip zero and a high positive integer (IEEE 1800-2023 Section 6.16.13)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.13 6.16.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_binary_octal_round_trip.expected
*/
// IEEE 1800-2023 6.16.13 6.16.14: Both conversion methods overwrite their
// receiver; the matching parsing method must recover each original nonnegative
// integer.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_string_binary_octal_round_trip;
  string binary_text, octal_text;
  bit valid_format;
  int values[3] = '{0, 1, 32'h40000001};
  initial begin
    foreach (values[i]) begin
      binary_text = "old content"; octal_text = "old content";
      binary_text.bintoa(values[i]); octal_text.octtoa(values[i]);
      valid_format = binary_text.len() > 0 && octal_text.len() > 0;
      for (int j = 0; j < binary_text.len(); j++)
        if (binary_text[j] < 8'h30 || binary_text[j] > 8'h31) valid_format = 0;
      for (int j = 0; j < octal_text.len(); j++)
        if (octal_text[j] < 8'h30 || octal_text[j] > 8'h37) valid_format = 0;
      $display("value=%0d roundtrip=%0d,%0d format=%0d", values[i],
               binary_text.atobin() == values[i], octal_text.atooct() == values[i], valid_format);
    end
  end
endmodule
