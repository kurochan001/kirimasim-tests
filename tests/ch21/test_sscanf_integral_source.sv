/*
:name: test_sscanf_integral_source
:description: $sscanf reads the characters of an integral value, skipping its leading null characters as white space (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_integral_source.expected
*/
// IEEE 1800-2023 §21.3.4.3: the text that $sscanf reads can be an integral
// expression as well as a string. Its value is read as characters of 8 bits
// each, starting from the most significant end, and null characters count
// as white space for $sscanf. So the zero bytes that fill a wide variable in
// front of a shorter string literal are skipped like spaces, and %s stores
// the word right-justified in a vector argument.

module test_sscanf_integral_source;
  reg [255:0] line;
  reg [63:0] word;
  reg [15:0] a, b;
  reg [15:0] digits = 16'h3432;          // the characters "42"
  integer n;

  initial begin
    line = "Hello 1f 2";
    n = $sscanf(line, "%s %h %d", word, a, b);
    $display("n=%0d word==\"Hello\": %0d a=%0d b=%0d", n, word == "Hello", a, b);
    n = $sscanf(digits, "%d", a);
    $display("n=%0d a=%0d", n, a);
  end
endmodule
