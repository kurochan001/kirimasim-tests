/*
:name: random_cross_case_0093
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0093;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0100100000000001100101100010111110101000111001101001010111111100,
      64'b0011111000111101000010101111001100111011101011011010000111010100,
      64'b1001010110010011011101000010010111110001100011101110011000101010,
      64'b1001110011001011010111110100011101111001101001110010010001010111,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010101001110100100011011010111111110101011001001000001011100010,
      64'b0100000011101101000110110010010001110011011111010111110001000101,
      64'b1110111011111010101010001010101111101001101110111011110000111010,
      64'b1111111000000000000010111011101110010100011001011100011111000111,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000011010111011011101110011010001111000111111101011000010001100,
      64'b0001100000111001100000111111011000011011110101011111111001001111,
      64'b1110011010101101000110000001110101000001101001011000010000001011,
      64'b1011110011101110111101001011100111100111001101000001001100111100,
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
      64'b1000011110111010110000100110110110001101001100110101000111111011,
      64'b1111101110100111100110011010110010111100110111101111010100101101,
      64'b1100101110001000110110110011100100111101101010110101011111000000,
      64'b1110001010111100001110111100001011110010111101000011111010101110,
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
      64'b1000000101001000110100101111010110001000000010011101010100011001,
      64'b1001000001110100110000110100001111111011000101011110101111111110,
      64'b0000100000101111110001110000100110001100000100101000010100100111,
      64'b1000010001111100011110101011001101001100101111000010100111011111,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0011001110000110111011111000101110001010111100111100100001011011,
      64'b0001011110001110100111101001010110000000000001001111001101010100,
      64'b0110011010111000001111001011011010001001011010111101100001001010,
      64'b1000000001001011010101011010110101100001100010010111100100100111,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110000010111001100000000100100101100100111100110010110111011001,
      64'b1001010011111010111101100110111011110010000101010100100011001010,
      64'b1100101000000001100011001001111100110000001001011000011000101111,
      64'b0010101000010010100011010111100100100111100100001010100010011110,
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
      64'b0010000100000100110111010111111000010110010000001010100100100110,
      64'b0001111001000111001100011011111100101110000100000111100100100111,
      64'b0011111110010100000001000011011101010001111110011110000100111000,
      64'b1100111001000000111111010101101110011100111111000110010100110110,
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
