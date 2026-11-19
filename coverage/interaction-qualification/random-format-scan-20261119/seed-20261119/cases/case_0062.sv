/*
:name: random_cross_case_0062
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0062;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1101110001011000000010001100000110011110111110000011001101100100,
      64'b0110110111000011110000101101010010000011111110110111001001011011,
      64'b0001110001011011000110010011011000111001011011111111011111110000,
      64'b0001001000000111011111100010000011010110001101100110100010100001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100100100000101000100101101001000010011001001110110011000101011,
      64'b1010111011011101010000011001101101111100000000000010110110010010,
      64'b1011000100000111011001110000001101110101100000101010011110100001,
      64'b0110001100001110000001100101111110101101000100110011101110100100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110101100000110111100100011101010011111001000001101100100010100,
      64'b1001000111010000111101111101000011000001101001000010110011100111,
      64'b0100100011110001001000010001101111001011110100000010111010101000,
      64'b1001000001111001101111101000101101100000011110101001011011010000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000000001111000100011000010011111001101101111110110011101010110,
      64'b1111110111111100100011001111101110001110011100101000011011111101,
      64'b1110011001110110011011111110100100011011100101001001011100001001,
      64'b0011110001010101011001100000111010010011001101110111101100011000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001011111011110101111110110010100000101011001001010000110010100,
      64'b0000010000000110000000011011010111110110011011011011001001111010,
      64'b0001101001000010011010100000000100001001000001111000000111101011,
      64'b0100000000010001100101011100000011101011100001110100011101101100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101010001011001010101010100110010101000011001000111110111011000,
      64'b1100100001100100111000001101101111011001111000100010001101111010,
      64'b0010011010111011100010101111101111101001011010001000001001011011,
      64'b1010011001101111100101011100000000001001010110101100001011011000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101100100110010101111111000011111101010011001100011010011011000,
      64'b0011000111101010000111000100110000111000011001010001011000100110,
      64'b1101111110100011010001100000100110011010100000110110100010010100,
      64'b1000001111100001111101001001100110110100100101111111001001101010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000010001010011110011110110111100011011001001000001000000111101,
      64'b0110010010110001110110001011000001100100001110001000100010000111,
      64'b0010111101011001111000011010111111000001110001100111001101010110,
      64'b1101001011111100001110101000110001100101000010011101001011100110
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
