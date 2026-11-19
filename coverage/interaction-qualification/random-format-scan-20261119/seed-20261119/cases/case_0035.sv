/*
:name: random_cross_case_0035
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0035;
  typedef bit unsigned [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0101111110101100000001000011001011000101100011000011100100111011,
      64'b0010111111110110111100100101111110000110011101110100001010000011,
      64'b0111001100001101100101101000010001010111111110101111010001000110,
      63'b010011110111111101111110110010000110011111001001010111011110111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011001100010010110100010011001001111000110110011011000011101110,
      64'b0101110100110010111001001111001101011100111101011110100101000101,
      64'b0010010111101110011001110111011110111000100000001001001101100001,
      63'b000101011001100010000110100011000110101110110001001110010101000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001010010100101001101000111101000000011101111000010011100100110,
      64'b0101001111011110010100100100010010001001010000110110111000010101,
      64'b1100111101000100110111111011010110110100001000001010111000111001,
      63'b100100101110110000000100100011100010111000110110110000010111000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011111000010100100010001110010010000001101011010010001110101111,
      64'b0011101011100001100100110010001110001110011111010111010011110011,
      64'b0010011010110110111100011000100000010011100111111111000110110000,
      63'b011101001100001001110100001111110001000110101110001011100101001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101001101000110101011100001110111010110011110011011100001000000,
      64'b0101111100010101011001011111001011111011010101011100110111101000,
      64'b1010000010011010111111010000110000011100101100101010011110110110,
      63'b001001010111101001010110000101111111111111001110010001111011100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001001110101101010100111011100010000001101010110101001100111101,
      64'b0110101010110111100011100001000101110011010110101001110101110110,
      64'b1010010001010001100100010001100101000011001110110000011111110110,
      63'b001100100000111000110110000000001111101010110010110101001101010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000100011000010010101010010001100011000101100000100011000100111,
      64'b1010001011000010101110010101111110001000001000111110011011101100,
      64'b1110101011111001101001011100101110001010010001011011101111110001,
      63'b111011000100110011110100111111100100111001111000100100101010110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100101001000011110100100010001110101000011010110111000111101010,
      64'b1111011100101111111100100110100101001001100110110111001000111101,
      64'b0110011001110000000010100101010001111100011000000010011011100010,
      63'b000100101001011110111011111000000010011000101110001111100100110
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
