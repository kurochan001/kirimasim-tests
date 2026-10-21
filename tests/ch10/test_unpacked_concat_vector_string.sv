/*
:name: test_unpacked_concat_vector_string
:description: When the target of a brace concatenation is not an unpacked array, the braces concatenate strings into a string and bits into a vector, including nested braces (IEEE 1800-2023 Section 10.10.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.10.2 10.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_concat_vector_string.expected
*/
// IEEE 1800-2023 §10.10.2: when the target of a brace concatenation is not an
// unpacked array, the braces are not an unpacked array concatenation but the
// string concatenation or the vector concatenation of the items. A string
// target joins the strings, and a vector target joins the bits, with the
// leftmost item in the most significant position. The inner braces of the
// nested vectors are again vector concatenations. A byte is wide enough for
// two 4-bit items, so b is 3a.

module test_unpacked_concat_vector_string;
  string s = "ab";
  byte b;
  logic [15:0] w;

  initial begin
    s = {s, "cd"};
    $display("string: %s (%0d)", s, s.len());
    b = {4'h3, 4'ha};
    $display("byte: %h", b);
    w = {{4'h1, 4'h2}, {4'h3, 4'h4}};
    $display("nested vector: %h (%0d bits)", w, $bits(w));
    w = {b, 8'h5a};
    $display("byte and vector: %h", w);
  end
endmodule
