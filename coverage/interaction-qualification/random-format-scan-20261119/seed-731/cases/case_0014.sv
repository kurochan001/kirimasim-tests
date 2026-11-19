/*
:name: random_cross_case_0014
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0014;
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1010111011101100111101010000000101000010010010001010001100000011,
      64'b1010111010101101001100001101010011111101010110101101111001110111,
      64'b1011110100100110010101001101000101010000110101010110011101110110,
      63'b110010100110001100000100010010011101111001010000000111000000110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001111110000010000000110001100011000010010000010100011001110110,
      64'b1001010110111110110011110010110111010110101010101011110010011010,
      64'b0110011100100010101010001000010100011000111010110111111110100100,
      63'b010001001110110001100001011101000101001100100010011100000101000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0100100100000101100110110011110100000000100001110011100100010110,
      64'b1011001000111001000010001011000010110000010001101101100000001011,
      64'b0110100000111010111111110111000111111010111101000110101110111010,
      63'b001111000101111000110001001100000110000111101000000110111110000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001100000110100101010101000110101001110111010011000111001111001,
      64'b0011110010111111010101001100100010111010100001111111100000111010,
      64'b0000010111101100101100100100001101101000100010110100010000100011,
      63'b001100000001110101101011010011111011001100111101001011101100110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010010011110110011010100100110000101001111111111001001110000100,
      64'b1101000110011100011010010010100000010010000101010101000010011000,
      64'b0011100000011111010101001011010011101101100101100100000001010111,
      63'b101011111000001111111011110111100110101001001110001001110000111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100110001001011000110011110111001010111001010000011101010111001,
      64'b0011111111111111101001011001011010111001111101001100110111011110,
      64'b1011111010110101001111110000011010000011000110000100000001101100,
      63'b001001011000000101110101101010011001011111011010100010101100011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110100011001100100100000011100010011100110011010001001001011101,
      64'b1000111101000010011110001011000011101101001000010111100100101010,
      64'b1010001110000101011110001011100010101000111110001111100101101011,
      63'b011111110110000011100101111110110011001100111101101001110001011
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
