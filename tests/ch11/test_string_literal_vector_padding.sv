/*
:name: test_string_literal_vector_padding
:description: String literals stored in vectors are padded on the left with zeros, which comparisons and concatenations do not tell from NUL characters (IEEE 1800-2023 Section 11.10.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.10.2 11.10.1 11.10.3 5.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_literal_vector_padding.expected
*/
// IEEE 1800-2023 §11.10.2: a string literal assigned to a wider vector is
// padded on the left with zeros, and comparison and concatenation treat those
// zeros like NUL characters of the string. So a 6-byte vector holding "hi"
// equals "\0\0\0\0hi", and concatenating two padded vectors keeps the padding
// in the middle. A string literal is an unsigned number (5.9), so a narrower
// vector keeps only its rightmost characters. §11.10.3: the empty string ""
// is the value 0, the same as "\0", and differs from "0".

module test_string_literal_vector_padding;
  logic [8*6:1] v6;
  logic [8*3:1] a3, b3;
  logic [8*2:1] v2;
  logic [7:0]   e;

  initial begin
    v6 = "hi";
    $display("v6 = %h", v6);
    $display("v6 == \"\\0\\0\\0\\0hi\": %0d", v6 == "\0\0\0\0hi");
    a3 = "ab";
    b3 = "cd";
    $display("{a3, b3} = %h", {a3, b3});
    $display("{a3, b3} == \"abcd\": %0d", {a3, b3} == "abcd");
    v2 = "hello";
    $display("v2 = %s", v2);
    e = "";
    $display("e = %h, e == \"\\0\": %0d, e == \"0\": %0d", e, e == "\0", e == "0");
  end
endmodule
