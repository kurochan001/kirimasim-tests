/*
:name: test_string_getc_index_rules
:description: getc(i) takes an int index, returns a byte equal to str[i], and returns 0 for an index below 0 or not below len() (IEEE 1800-2023 Section 6.16.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.3 6.16 20.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_getc_index_rules.expected
*/
// IEEE 1800-2023 §6.16.3: byte getc(int i) returns the code of character i,
// and 0 when i is below 0 or not below len(). x = str.getc(j) means the same
// as x = str[j] (§6.16, Table 6-9: an index out of range reads 0). The test
// reads each index with getc and with an index into the same string. A byte
// is signed, so the character 8'he9 reads as -23. $typename and $bits
// (§20.6.1) show the type of the call; the index 64'h1_0000_0002 is converted
// to the int 2.
// Icarus Verilog 13.0 rejects getc() as the argument of $typename
// (unsupported construct). Verilator 5.052 gives getc() the unsigned type
// bit[7:0] instead of byte, so it prints 233 for the call shown directly;
// the standard requires byte, which prints -23.

module test_string_getc_index_rules;
  string s = "Az\xe9";
  string e;
  int idx[6] = '{-1, 0, 1, 2, 3, 99};
  byte m, x;

  initial begin
    $display("type: %s bits=%0d", $typename(s.getc(0)), $bits(s.getc(0)));
    foreach (idx[k]) begin
      m = s.getc(idx[k]);
      x = s[idx[k]];
      $display("i=%0d getc=%0d index=%0d", idx[k], m, x);
    end
    $display("int index: %0d", s.getc(64'h1_0000_0002));
    $display("empty: getc(0)=%0d getc(-1)=%0d", e.getc(0), e.getc(-1));
  end
endmodule
