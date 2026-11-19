/*
:name: random_cross_case_0049
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0049;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0011001110011000011101010001000101110111110101111001110101011110,
      64'b0110101101111001100101101101100110010101001010101000011011010110,
      64'b0110100101011001100010011100000100101001101001111111110101111011,
      64'b0101001101100000010100100011000010110010101101011001110100011110,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111101010010101010110001011100100110011111001010111100001011011,
      64'b1010110010011011011100101000101101101001111010111111000110011110,
      64'b0011100010111111000000101100010001111010100111011110001010011010,
      64'b1101010010110101110100011000110010011011011110001101110010011011,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110010100010011011111001101101110000000000101000101100111011011,
      64'b1010001100110001010010100100110010100111110010111100101000110110,
      64'b1000100100100101011101011010100100110001000101001011010110110001,
      64'b1100011011111001101101100011000100011101011010000111001111011111,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000001110110100110110110011010011000111001010110001110111001111,
      64'b0100000001010110010011000001100001000110000110111000111010010111,
      64'b1010001011101010000001101101010110001000111001001101001101010110,
      64'b1001100110011010101101000011100000101101111100110101000000111100,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010110101011100011000000001110111011010001111000101110010101100,
      64'b0111010010010101011001110000111011111001011111111001111010111100,
      64'b1010001100011111101111110011100111110111010011111100000111100011,
      64'b1101101100011010110011100101111110000011000011010101010001000010,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111001010110100101111001010101000111000001110001100111001000001,
      64'b0100100010110011011101010100011010111011010101011110010000110100,
      64'b1011111100011110111010100011011101101001101100100000010100010100,
      64'b1001101000011100111111101100100101111000000001110000100010010001,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v7_input=%b", source);
    $display("v7_text=%s length=%0d", text, text.len());
    $display("v7_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    $display("widths=%0d,%0d", $bits(source), $bits(parsed));
    $finish;
  end
endmodule
