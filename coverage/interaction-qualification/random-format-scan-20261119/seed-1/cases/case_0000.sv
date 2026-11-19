/*
:name: random_cross_case_0000
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0000;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0101100000000100111110010010001010000011100001101000101000101001,
      64'b0110011110001010010110101010001100111011011011111110010100000111,
      64'b1000110001011111111010001111100011011100001110111111001101100100,
      64'b1110101110001010110010001100111010001010001001000101111001101011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011101010111001111110000111111111110101000001011001001010000101,
      64'b1001101111100011110011101100101110001100010010010111110001101000,
      64'b1010100011000010010011010100001001000100111011110111111111101011,
      64'b1110100011100101101101000110000101110101100010011010100000101011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111101100101001011111010000101100001110010111100001100010111010,
      64'b1111001100100000110011010101011101101101000101000100011101011011,
      64'b0011010010011010101011101001000010001111101101010010011000101100,
      64'b1100011100000011100000000110100110000100110010000001100110011001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101000000110111110011011111111101111100001001000000110101001001,
      64'b0110100111010100100101011101110110000001001101010101110001010011,
      64'b1111000011100110010000101111010000110011001010001010110100001000,
      64'b1000110111101101001111001001011010010001111010110111100111111010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001110011001001101011110100111011001001010101000110101101000011,
      64'b1001111110011101000000010010100110001010010001001001111010111110,
      64'b1000100111011001101111110000001000000000011001111101101110101000,
      64'b0101100010011000100100000000100001101010000101111011100110101111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000110011111110010111001101000100101101010111011011011110011011,
      64'b1010001010100111101011100001111100111010110001110110010100101100,
      64'b1100110111111000010001000000010000000111001010010101111001000010,
      64'b1001100110010000000111000000010001110101010010010001101111000011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110111001010010101111011011011011010001000000100000101000010101,
      64'b1101100111101101000101111110001111001100000011101001010111101110,
      64'b1000110100010000001111101101001111001100011001100111111010010111,
      64'b0001011101110011001100001000110011011100011010110001001110101011
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
