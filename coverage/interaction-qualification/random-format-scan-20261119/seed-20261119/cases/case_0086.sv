/*
:name: random_cross_case_0086
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0086;
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1001111001010010010100110111111001101000000001010001111001101101,
      64'b0000001010100001000111001011100110111111010100110101011010110111,
      64'b1110010010110110101010001100110100110000110110110111010111101000,
      63'b000101101101111110101010001101001101011110001101100011000011110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110000000011010011001100101111010001100101010100011110111011110,
      64'b1101000001010000101100010011101011011101001001100011011010010011,
      64'b1010011000101101001101111001111110011010101110100001110110101000,
      63'b001000111010011100010100110011110000010101010110111011110110110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111110001101101100111010101000000100011101110011001101110101001,
      64'b1011100110111110111010101101111001000011111010011111010101111010,
      64'b0011001011110000000001101010000110101000011101100100000111001100,
      63'b000111001010001011101101111010110100101100101100110000111001100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110110111000111110101110100110001010010000000100000001000001011,
      64'b0000010111101101000001011001010011000010001110011010011100010010,
      64'b1100010100000001111000101110001111000011010100000101010101010000,
      63'b110101010101001001100100001100011110111000011011101000100010101
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000011001010110100110000101110101000110010000111110010010101000,
      64'b0111110011001011111010110110100010110010010011110100100011011000,
      64'b0000111100000001011000100010000110100101101101100010110111010101,
      63'b111010011001101110000111100110100011100110101111001001100111110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001000111011001111000101100101101010101010101011010000011000001,
      64'b1110011111111001001100111010000000000000110110110010101011101001,
      64'b0000001000111100001100000011110101001001111100111010110011000100,
      63'b010110101111011010001101011111011110001011100100110101011100110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011111010110101110110000010011100010100011011000110011111100111,
      64'b1101000001000000111111010010011001001111000011100000100011101110,
      64'b0000010000110100100101101100110001011101000100001001011110111001,
      63'b000110011100101110000100010011101110110111000101111011100011011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
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
