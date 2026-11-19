/*
:name: random_cross_case_0040
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0040;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111001000000011110001001011011110110111011111000010101110110101,
      64'b0111110010110011110000111111111001100011001101010001001101000110,
      64'b0000001110100000001010111010011101100101111001010011000010101001,
      64'b0100011110110110000111000101001011110000000001111110110000011111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101100101100110000000001001101001010000001010100101011110100011,
      64'b0110001100010000000111011001001110010100110010001010011000101100,
      64'b1010010011000000010100001110110101001101100101111011010110100000,
      64'b1011011001011110000101000001110110111101101001001111010110101111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001101100000000110010111111110101110101011011111110100100000000,
      64'b0010011101000000111001000000111001110010000111101000010000000101,
      64'b0010111000000001111110001111000001111101010001100001010011110110,
      64'b0001100110101110100110100001011100101100100101001100110111010010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110111101010001010001011101010110001111000110110001111000100001,
      64'b1010110101000110011000101011000111110011100101001001110111010001,
      64'b0111111010001000001111111010101111010010111110001011100101010100,
      64'b1111111010100001110011100000100101010000111111000010100111011010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101001011000010100111100111111001110110011011000101110011001010,
      64'b1100110010001111100011000101111110010111101000000101100011101100,
      64'b1000111111110111000100010010011001010001110111101110110010001101,
      64'b1001010011010100111000010001000110111001010000001100011011000110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0011110110110011101011111001001100101010100001000110101111100000,
      64'b0011011111010111101011011111101011101000010111010100101001111000,
      64'b1000100101001000010010000100011111010010111000001111001000101110,
      64'b0110010011100110001111110000110110110000111001100100000010011001
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110011111000001110011010101001101010010001010010100111001101100,
      64'b1100011111010111010101111101011100001101001101111000011000110110,
      64'b0011111011001101111001111001110011101110111101111111011101110000,
      64'b1001100000110000010111101111111011011011110111011001010111010010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v7_input=%b", source);
    $display("v7_text=%s length=%0d", text, text.len());
    $display("v7_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    $display("widths=%0d,%0d", $bits(source), $bits(parsed));
    $finish;
  end
endmodule
