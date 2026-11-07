/*
:name: test_integer_unsigned_keyword
:description: an integer declared unsigned holds all ones as 4294967295 and compares and shifts as an unsigned value, unlike an integer (IEEE 1800-2023 Section 6.11.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11.3 11.4.4 11.4.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_integer_unsigned_keyword.expected
*/
// IEEE 1800-2023 §6.11.3: integer is signed by default, and the keyword
// unsigned makes it unsigned; both have 32 bits (Table 6-8). Each variable
// is given all ones ('1, 5.7.1).
// Shown in decimal, the unsigned one is 4294967295 and the signed one -1.
// Compared with 0, the unsigned one is greater, as a comparison with an
// unsigned operand compares unsigned values (11.4.4), and the signed one is
// not. Shifted right by 31 with >>>, the unsigned one is filled with zeros
// and gives 1, and the signed one is filled with its sign bit and gives -1
// (11.4.10).
// Icarus Verilog 13.0 shows the unsigned one as -1 with %0d, although it
// compares and shifts it as unsigned (see docs/simulator-differences.md).

module test_integer_unsigned_keyword;
  integer unsigned u = '1;
  integer s = '1;

  initial begin
    $display("bits: u=%0d s=%0d", $bits(u), $bits(s));
    $display("value: u=%0d s=%0d", u, s);
    $display("greater than 0: u=%0d s=%0d", u > 0, s > 0);
    $display("shifted by 31: u=%0d s=%0d", u >>> 31, s >>> 31);
  end
endmodule
