/*
:name: random_cross_case_0059
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0059;
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111100000010100110110111011000001010010100100110000011010001000,
      64'b0100011111001110101100101111110111100010110100111111110000011101,
      64'b0001001000111011000110101011110111011101101000111111111000101111,
      63'b100011010110110010101011101011110000001011101100010111100110011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000011011100101010101000001111001000000101000001101101111011010,
      64'b0101111001111001000010000100110000000001001101001110001110110001,
      64'b1011110010101011110001101011011110111101011101001111011010110010,
      63'b010001100111010101100011101000001101001110010011010101110111110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011101101110101001010101001000011101010110001110111000111100001,
      64'b0111111001000111001010110000000110110110110110101100000111001000,
      64'b0010001101100010000000101010000010100000001110011000100100111101,
      63'b000101111111101011101111100101000110100010010101011101001111010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110010010100101111100010101111000010111011111010111110110110110,
      64'b1110010100010010110101010010101111111000000101010111111110110101,
      64'b0101011011110111110001110001000111011110011010100111110010011111,
      63'b010100001001010101000001111101010110111011010000110101000001101
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100000101001110001110010000011011110011110010011100001100000010,
      64'b0010111000010011101110010001111000011100010101100001011000000100,
      64'b0000110010001101101010000110010111100101010010000000001101001011,
      63'b110001011111010110000100010000000111100011110001000111111010110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101011111011000010011111110111100100001101101001010100100101000,
      64'b1001011110001001101100101010011001000100101001011010110001111011,
      64'b0101001111010111010110100011001000101001101100011010111011011110,
      63'b001111100100110101011001001000011000000001100001010100001100001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110110001101101000010100111100010011101101100001011011100000011,
      64'b1001111001001010010000010001100001101001100011000111111111000111,
      64'b1111001110011110111101110110110001110100111010101011011100000101,
      63'b100111010011100010101100111101010110110011111101101111110011001
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
