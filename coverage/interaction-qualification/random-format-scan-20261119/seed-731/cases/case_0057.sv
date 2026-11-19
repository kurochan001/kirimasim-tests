/*
:name: random_cross_case_0057
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0057;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1100101001010000011111101000101000111101010100100001000111010101,
      64'b0110011101010101000001101011110111011101000000111011101000110001,
      64'b1101100100001001001111001100101110010010010000111011001100010001,
      64'b1010001000000001011111110101101001100111000101111111000110111010,
      1'b1
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      1'b1
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011000011111001011000111010111110000010101000100110101110011010,
      64'b0100010100000010110011101000100110101111110001111111011101010100,
      64'b0010110101111000000110101000010100101001110111000110011001001011,
      64'b1100011010010001000100101111001010111001101010111100111101010110,
      1'b1
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100111001101010010101010100001111110100111111011000011000010101,
      64'b0100001010001000100000111101101110000011011101000000111101011000,
      64'b0010011101010111010001101110011100011100110010110110000000101010,
      64'b1011100000110100110011101110011001000110011111010011101010100111,
      1'b0
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001000001000000000110010011101001011011011101100100111000010001,
      64'b1100100110101011101101011011001101010000010110011000010001001111,
      64'b0000110111001101101100000111011000011000110100101111001001100101,
      64'b1110011001010111101111100001000110110010110100111000011101100111,
      1'b0
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101111011000110110110101110110101101000001000011100010100110100,
      64'b0101010010000111001011000111101000101000010111101010101001011010,
      64'b1011011011010111001001100010100101100110110101101110100101110011,
      64'b1110111110100111110010101010010011101101001010010001010011100001,
      1'b1
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111110101101100101101111000110110110000110001100101011000100111,
      64'b1001111010000010110001011100100000010101000011101001001100110010,
      64'b1011101100011010110000010001100011000110000101010101110000011010,
      64'b0010000001000000000111101101101000101100011000111000001111010110,
      1'b1
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101011101101111011010111011001100000010111011100000001111110101,
      64'b1011000110111101111100111011101101000110000100110000111011111011,
      64'b1100011000010100011110110111111000010000101101100011100010110001,
      64'b1001101111000100111101111011110000111000111110111110100011000101,
      1'b0
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
