/*
:name: random_cross_case_0004
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0004;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1011010010101101110110111010111110010001110111000111010011110001,
      64'b1111011101011100011100001000001101001001110011001110100010111010,
      64'b0000110001111001110011110111101101010010000110100100111011110110,
      64'b0001001101001000011110101000111110110001000111011101100100011111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000000010111111000110111000101101000101100101000001101000000101,
      64'b0110001111101010000010010110010101100010111110000111111110000010,
      64'b1100010001001011001010100001111000110101001100100100100101100100,
      64'b0011110001101001100101111101000100001010111111011000111100001000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110111101100011111111100010011110101101101000100101110010000100,
      64'b1001010111001011010000011001000001000000111011110001010010111011,
      64'b0110010010011011010110100011111001100111001111110000001100111101,
      64'b0111001000011000100101010110001101001011001101101100011111100001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0100101111001110001111110100110000111000110111010110100000011100,
      64'b1100000001101010100001001110111110011100100010001000010101001100,
      64'b0111111010111001101000100010110110101110010010011110010010011000,
      64'b0101010101101011010111001100110000101000100000011101101100110101
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001110011100001001000110000010110110111101101000101111100100111,
      64'b0011110111100010011011110011001000101010110001011101001101111001,
      64'b0010111001011111101011110011110011000100100111101000011101111011,
      64'b0110110001011001010110001000000000100101000111001100111101110000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0011101011001001000010100100011111110000111111010001000111110101,
      64'b0011000101100110111110000101010111001101100100100111110010101011,
      64'b0100011100010110111110100000000001101011011101101000011111111111,
      64'b0101010110001110100000001110000001101011010111110100101101000100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111101110010101111001001001101100101110110111010110010011100011,
      64'b1110000101000010011110101000000110011010111010000011101101101111,
      64'b0101001111001101111001101110111000000001110010101011011010000000,
      64'b0111101011100111101100011000001100111110011010101000001010010101
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010001100011111000111001010011000100101111111101110011011111111,
      64'b0000111111001000111011010110100001111010111110001100100110000110,
      64'b1011100100011111111100100000011110110011000011011110011110110100,
      64'b1111100110100101110001111111111010010011101101010010000101100101
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
