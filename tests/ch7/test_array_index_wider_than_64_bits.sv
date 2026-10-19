/*
:name: test_array_index_wider_than_64_bits
:description: An index of an unpacked array that is wider than 64 bits selects by its whole value (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5 11.4.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_index_wider_than_64_bits.expected
*/
// IEEE 1800-2023 §7.4.5: the index of an unpacked array can be an expression
// of any integral width, and its whole value selects the element. An index
// wider than 64 bits is not cut to its low 64 bits: 2**64 + 3 is out of
// bounds, not 3. Reading with an index out of bounds gives the default value
// of the element type, 0 for int (Table 7-1), and writing with it does
// nothing. A shift of a 65-bit value (11.4.10) gives a 65-bit index.

module test_array_index_wider_than_64_bits;
  int arr[8];
  logic [64:0] two = {1'b1, 64'd2};        // 2**64 + 2
  logic [64:0] three = 65'd3;
  logic [64:0] far = {1'b1, 64'd3};        // 2**64 + 3
  wire [31:0] w = arr[two >> 63];          // (2**64 + 2) >> 63 is 2

  initial begin
    foreach (arr[k]) arr[k] = 20 + k;
    #1;
    $display("arr[two >> 63] = %0d", arr[two >> 63]);
    $display("arr[three] = %0d", arr[three]);
    $display("continuous arr[two >> 63] = %0d", w);
    $display("arr[far] = %0d", arr[far]);
    arr[far] = 99;
    $display("arr[3] after a write to arr[far] = %0d", arr[3]);
  end
endmodule
