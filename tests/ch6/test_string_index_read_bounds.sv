/*
:name: test_string_index_read_bounds
:description: Indexing a string reads the character code as a byte, index 0 is the leftmost and len()-1 the rightmost character, the result equals getc, and an index below 0, at or above the length, or into an empty string reads 0 (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 6.16.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_index_read_bounds.expected
*/
// IEEE 1800-2023 §6.16: the characters of a string of length N are indexed
// from 0, the leftmost, to N-1, the rightmost. Str[index] returns the ASCII
// code of that character as a byte, the same as Str.getc(index) (6.16.3), and
// an index out of that range returns 0. Indexing an empty string is always
// out of bounds.
// s is "Hey!" (codes 48 65 79 21 in hex). Each index from -1 to 4 is read into
// a byte, shown in hex, and compared with getc; $bits shows that an indexed
// character has the 8 bits of a byte. The empty string e is read at 0 and -1.

module test_string_index_read_bounds;
  string s = "Hey!";
  string e;
  byte c;

  initial begin
    $display("len=%0d bits=%0d", s.len(), $bits(s[0]));
    for (int i = -1; i <= 4; i++) begin
      c = s[i];
      $display("s[%0d]=%h getc=%h same=%0d", i, c, s.getc(i), c == s.getc(i));
    end
    $display("last=%h", s[s.len() - 1]);
    $display("empty: len=%0d e[0]=%h e[-1]=%h", e.len(), e[0], e[-1]);
  end
endmodule
