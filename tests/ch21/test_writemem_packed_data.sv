/*
:name: test_writemem_packed_data
:description: $writememh and $writememb write each packed element as one value, as $readmemh and $readmemb read it, so a memory of packed structures or packed arrays reads back unchanged (IEEE 1800-2023 Section 21.5.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.5.1 21.4.1 21.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_writemem_packed_data.expected
*/
// IEEE 1800-2023 §21.5.1: $writememh and $writememb treat packed data as
// $readmemh and $readmemb do (21.4.1): each element is written as a single
// value of all its packed bits. A memory of a packed structure and one of a
// two-dimensional packed array are written and read back into fresh arrays.
// The test creates its files in the current directory.

module test_writemem_packed_data;
  typedef struct packed {
    logic [3:0] tag;
    logic [7:0] data;
  } word_t;

  word_t words [0:2], words_back [0:2];
  logic [1:0][3:0] nibbles [0:1], nibbles_back [0:1];

  initial begin
    words[0] = '{tag: 4'h1, data: 8'h23};
    words[1] = '{tag: 4'ha, data: 8'hbc};
    words[2] = '{tag: 4'hf, data: 8'h00};
    nibbles[0] = {4'b1001, 4'b0110};
    nibbles[1] = {4'b0001, 4'b1111};
    $writememh("test_writemem_packed_data_h.mem", words);
    $readmemh("test_writemem_packed_data_h.mem", words_back);
    $writememb("test_writemem_packed_data_b.mem", nibbles);
    $readmemb("test_writemem_packed_data_b.mem", nibbles_back);
    foreach (words_back[i])
      $display("words[%0d]: tag=%h data=%h", i, words_back[i].tag, words_back[i].data);
    $display("nibbles: %b %b / %b %b", nibbles_back[0][1], nibbles_back[0][0],
             nibbles_back[1][1], nibbles_back[1][0]);
  end
endmodule
