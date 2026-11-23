/*
:name: test_assoc_wildcard_packed_key_order
:description: A bit-stream cast exposes the unsigned numeric order of wildcard associative keys
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.1 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_wildcard_packed_key_order.expected
*/
// Wildcard keys have their own widths and are treated as unsigned (7.8.1).
// A bit-stream cast places the value at the smallest key in the most
// significant byte (6.24.3). The signed eight-bit key 'hff sorts between
// 16 and 256. Replacing key 16 moves a different byte to the high-key end.
// Icarus 13.0 rejects the wildcard declaration. Verilator 5.054 does not
// support the cast from this array to a packed word.
module test_assoc_wildcard_packed_key_order;
  typedef bit [31:0] word_t;
  byte unsigned values[*];

  initial begin
    values[9'd256] = 8'h57;
    values[8'shff] = 8'ha2;
    values[4'd2] = 8'hd4;
    values[5'd16] = 8'h19;
    $display("initial=%08h", word_t'(values));

    values.delete(5'd16);
    values[32'h8000_0000] = 8'h08;
    $display("replaced=%08h", word_t'(values));
    $finish;
  end
endmodule
