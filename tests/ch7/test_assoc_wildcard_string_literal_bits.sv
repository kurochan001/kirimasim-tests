/*
:name: test_assoc_wildcard_string_literal_bits
:description: String literal wildcard keys alias equally wide packed integral values (IEEE 1800-2023 Section 7.8.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_wildcard_string_literal_bits.expected
*/
// A string literal becomes an equally wide bit vector rather than a key
// in a separate string namespace. Length distinguishes A and AB.

module test_assoc_wildcard_string_literal_bits;
  int a[*];
  initial begin
    a["AB"] = 11; a[16'h4142] = 22;
    a["A"] = 33; a[8'h41] = 44;
    $display("num=%0d AB=%0d bits16=%0d A=%0d bits8=%0d",
             a.num(), a["AB"], a[16'h4142], a["A"], a[8'h41]);
  end
endmodule
