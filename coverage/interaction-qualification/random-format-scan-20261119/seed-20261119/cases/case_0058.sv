/*
:name: random_cross_case_0058
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0058;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1010110100111001010010010011111000010011010010101011010110001100,
      64'b0010100110100011101001000010111010011001001001001011010001010010,
      64'b0011010101011111011010011101111100011111010100001011001000111101,
      64'b0100110001000000000110001101100100110111010110101100101111000011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110001110011010011110001011001000111110010001110001000100110001,
      64'b0010001110110111010010001111110110111011000111011010111101110101,
      64'b1110111110110101110011101001010111000010101100111001101111111001,
      64'b1100100001001010100111000010101001000111101001000011010001001000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000001001011100010001001110101100001110110000000000010101010000,
      64'b1110001001110100100110000000000010110011011111101101010111010111,
      64'b0100111000000110011111100101001110110001100111101101110001010111,
      64'b1001000011111101001001000111001000100110001011011110110011011001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000110001010000011111010000111110100111010111110111011011001101,
      64'b0000000000001110000110110110101101010110011110101110010001110011,
      64'b0110001010000111111101100110000000111000000011111011111101100011,
      64'b1011100111101100000011111001010000001110101110111001101111110010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110100000001000000111001111100000101111100011110101100101110000,
      64'b0111110011100000000000001010100001001101010001001110011100000100,
      64'b0110000000111000110011011110100010101111011111111001001101110000,
      64'b0000101100100001000001000110111001100101110111101011010010001100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101000000110010001000000001011001001100110011010101101101110100,
      64'b1001010000000100110000110110000010110011011010000001110010010001,
      64'b0110110111000010111100101000100100010011100101100001100010101011,
      64'b0000001101100001101010110101000101101001110001110011000111111110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000111111000000000100000101001100010100101110011001000011000001,
      64'b1101100101010111001101101100010110110001011100010110101101001110,
      64'b0101110001011000010001111010011000101111110111101100000011100110,
      64'b1110100000011010000001011010111010101100011101101101011101101000
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
