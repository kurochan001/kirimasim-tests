/*
:name: random_cross_case_0073
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0073;
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1111011000110011011000011000000111001101101010000100101011101101,
      64'b0101001000111110110011110000010110010111101011000011010000010101,
      64'b1111111100110111111000101100001100110101000010010110000110100001,
      64'b1111010110110110001001010111101101101000010010101110100111001100,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111010111111010001100000010101010011111100100101101010111111011,
      64'b1001110001010100101101101111111110111011010001001011111000010110,
      64'b0101110100101101111101001111110111101101000011101100111101000110,
      64'b1110110000000001001011001111001010110000000000000101100011100000,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000111000000010001010111001100011100000100101010100010011111010,
      64'b1010110100001111111111011001100111101101011100001100100001010001,
      64'b0111100000010010101111100101011011110010100101000010000000000000,
      64'b0011111100101010100001011110101010111100101100000111100111101010,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001011010000110010100101100011111101010100010011011101001110011,
      64'b1101110101001001101000110110010001111000011001111001000011110110,
      64'b0000011111100101011010011011010110110101111001101001001110101101,
      64'b1001101110000101010000010000011110110001101010111110010010100011,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100000110000000111111111000111101110010100101001110110100100111,
      64'b1000100010110011010001011010111111100110011000000111000001100010,
      64'b1001001000100011110011001110111011000011010001110110111001101110,
      64'b1010111111010000100011111101001000110110011010011110101001011010,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111001011110011101010100111001101000101100100101100000001100001,
      64'b1100000001011010000000111001010001100001001110110101001111100111,
      64'b0001101100100111000010010111110001100011010101100100001011100100,
      64'b1100101010000100000011111010010100000101110000010000101110000101,
      1'b0
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
