/*
:name: random_cross_case_0008
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0008;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0011010011100100100010110111100110000101010100100101101110001111,
      64'b0000010011111100010101110001101010001101111110000011000101111000,
      64'b0000100111011110010100100110100111101010000101101011110010011100,
      64'b0110110110101011101111000000001010010111011101111000011000011001,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111001111101010100110111011110001010010010100011010011001011101,
      64'b0000001110010110111010000101100011011010010100011100100011100110,
      64'b0111101011100010001011011010100111110011001001111010010011001100,
      64'b0101011001110101010110110100001101111111001001110111111001110000,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0100111101011111111001100101001111100100101010000011000111110011,
      64'b0011100010100001100111011111010000101000000010001010100100110000,
      64'b1101010001100100000111100111011110011000100110111101011010000001,
      64'b1101111101100101101000000101111011010111111101101101111001000011,
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
      64'b1011100110010011111110011100101001100010111000110011000000101101,
      64'b0001010100111001100110001001001000010001111010010001100000010110,
      64'b0101000111011100100000001100011100001111001110011110001011110111,
      64'b1001100011111010110101010100101001000100010101101001101000101100,
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
      64'b0101110111101111100010011110000001001101001010110010111111110010,
      64'b0011010000100100010111111010011101011001000101100011100110100111,
      64'b0100111110101101110110001111000111000100001000001111001000000011,
      64'b0101111011110001010101110010010100110100110000111110001000011001,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000110100110011000011011001000000101101010111011010110010111111,
      64'b1001000101000001001101000001110010111010111111101001010101101011,
      64'b1100001101000010001110111101110000101101001001001101101001010001,
      64'b0010100000101000011100000110101010100000001010100111001100101010,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111000101000100111011011101110010000001000111000000010100111111,
      64'b1001101010010010000001000001011000101011011110000100111110000001,
      64'b1101101101010000010101000101100101101000001001110100110001111011,
      64'b0011010110001110100100100100011101001011001011001101010010110001,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001100111010100111111101010111100111101000111100011111111010000,
      64'b1110100000101000100011101011000011110100110011010011010110011101,
      64'b1101110100110111111011000011111010011001010111000110100111000100,
      64'b0111101111100111011001010110100101111110110100110001000101101001,
      1'b0
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
