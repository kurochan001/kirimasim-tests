/*
:name: test_string_octtoa_bintoa_negative_round_trip
:description: octtoa() and bintoa() accept negative integers, replace the receiver, and atooct() and atobin() read the result back as the same negative value (IEEE 1800-2023 Sections 6.16.13 and 6.16.14)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.13 6.16.14 6.16.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_octtoa_bintoa_negative_round_trip.expected
*/
// IEEE 1800-2023 §6.16.13 and §6.16.14: octtoa(integer i) and
// bintoa(integer i) store the octal or binary text of i in the string, as the
// inverse of atooct() and atobin() (§6.16.9, which return a 32-bit integer).
// The argument is a signed integer, so negative values are accepted, and
// reading the text back gives the same value. The exact text is not printed,
// since the standard does not fix how a negative value is written; the test
// prints whether the old text is gone and the value read back.
// Icarus Verilog 13.0 does not know atooct() (unsupported construct).

module test_string_octtoa_bintoa_negative_round_trip;
  integer v[4] = '{-1, -8, -123456, 32'sh8000_0000};
  string o, b;

  initial begin
    foreach (v[i]) begin
      o = "previous text";
      b = "previous text";
      o.octtoa(v[i]);
      b.bintoa(v[i]);
      $display("v=%0d replaced=%0d,%0d atooct=%0d atobin=%0d", v[i],
               o != "previous text", b != "previous text", o.atooct(), b.atobin());
    end
  end
endmodule
