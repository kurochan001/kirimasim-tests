/*
:name: random_cross_case_0078
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0078;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1110100000001101010000111111010011100101110011100101010010011010,
      64'b0101100010011010110100011001000111100000111001101010011110000111,
      64'b1010100100111011001011010110000010000101010000000111101010011101,
      64'b1011010100010011010111110010100110010110001010100111011000000011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011011110101010100100000001110010111111100010100101111001110110,
      64'b1101101111001111110111101001011000000110101001011110111110000100,
      64'b0000001110010110000100011000000110110000100101000110001111110101,
      64'b0000000101001011110111001111001001000100011001010111111010110001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000110000010100100001111011101000110000000111100011111110110111,
      64'b0110100101001001001001100111110010101111111011000011010011001110,
      64'b0010001100110000100011011000010000010010110011101111001111011011,
      64'b1101110001100011000110001111101100000011101001111100101010111100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001100000010110110001000011100000100101100011110101011110000001,
      64'b1100101111000010110110010001110010111111101111110010100101101101,
      64'b0101101100001010101000111011111000101100100000100000100011001110,
      64'b1111110000000100001000100010111011111010111011101011001101101001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111110111101011100011100010000110001110010010111111011101001111,
      64'b1110111000101011110010110110011000010110011110111011010000100011,
      64'b1111011011010010100000110001000010011010011101011101110110100111,
      64'b1001100001011011110010101111101000010110011001011011110001110000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111000101011111100100101000011000000100010100000111111100101111,
      64'b0110110101101100110001001010010011100101110110010010100111101001,
      64'b0011110101100001111111100111000010101110000100101000110100101100,
      64'b1011001001011101101110001100100001111111011111111010110101100000
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
