/*
:name: test_string_literal_to_unpacked_byte_array
:description: A string literal assigned to an unpacked array of bytes fills it from the left element, padding the rest with 0 (IEEE 1800-2023 Section 5.9)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9 7.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_literal_to_unpacked_byte_array.expected
*/
// IEEE 1800-2023 §5.9: a string literal can be assigned to an unpacked array
// of bytes, one character per element. When the sizes differ it is left
// justified: the first character goes to the leftmost element, bb[3] of
// byte bb[3:0] and bl[0] of byte bl[0:3] (7.4), and the elements after the
// last character are 0.

module test_string_literal_to_unpacked_byte_array;
  byte bb[3:0];
  byte bl[0:3];
  byte be[0:2];

  initial begin
    bb = "hi2";
    bl = "lo3";
    be = "abc";
    $display("bb[3:0]: %h %h %h %h", bb[3], bb[2], bb[1], bb[0]);
    $display("bl[0:3]: %h %h %h %h", bl[0], bl[1], bl[2], bl[3]);
    $display("be[0:2]: %s%s%s", be[0], be[1], be[2]);
  end
endmodule
