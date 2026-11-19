/*
:name: random_cross_case_0079
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0079;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0110000101011010000011011101010010101101101011000010010101001011,
      64'b0011101010110101010101010100000011100001000100100110001100011111,
      64'b0001011011001010000000001100100011111101000011011111100010100000,
      64'b1101101010011001100111010100001110000110000000100010100001001011
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0100111101011001101110000010100111000000011000100101101111000010,
      64'b0010110110101101001010001000011101000111000010101111000000110000,
      64'b1001101110110011001001011010010110111100000100000001111101010011,
      64'b0100101111011000111011111001100111001000100101111001010111000100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001010101100111100010101010101011000011000101110001010010100100,
      64'b0100101001000110110101010011001100100000110100100000101110000111,
      64'b1100110101100111010101011101000010111001000010111101101010101100,
      64'b1111001001110111101001001111001101010110010101010100000010111111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111110010101110110101110001101011010101000110100110110101011000,
      64'b1010101001101101011000010101110100011010000111111000111110111011,
      64'b0101010010100100011100000111101010101101001011000100000100110101,
      64'b1010011000110001110000111000001010111001001001100101110010000100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100010011001111001001011011110001111111111110000011010000001010,
      64'b1101001110101101000101010010011011010101011110111101111000000110,
      64'b1101011000000101001100001000011001010010001111011001110110010011,
      64'b1010011000110000010010100011011010011100011001110111000100111000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110111010101010111111100000000111111101001000001010100010010001,
      64'b0111001011000100100010001110001100111101101010101001011010010011,
      64'b0110000001011110110010110000111100001101100100111011001001111000,
      64'b1111000011111111100000110111011101110011110010111000101100111110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011100100011011110110111100010101111011100000100100100110000100,
      64'b0100010100011110011101001100110100011111100100011110000101010000,
      64'b0010011110100001101110110110100001000011011111111110010011001100,
      64'b0100101111000001001101000010000011000101011010010100101001011101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111100100111011000001011010101101110101011110010010001001111100,
      64'b0010100100011100001000110101000011110000110011110101011110110000,
      64'b0011101010110000100010110101011000001111101100000000101001010010,
      64'b0101011010111110011111110101101010011010101100010111100101101111
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
