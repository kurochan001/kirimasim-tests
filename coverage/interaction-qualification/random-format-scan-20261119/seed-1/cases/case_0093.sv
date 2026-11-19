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
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0010000000011011001000001111101111110110000101000000110000101111,
      64'b1111011011111001000010010000010101100000100000010110100101100010,
      64'b1101010100100011110111010111011101011011010000110010011001101000,
      64'b0010110110000110101001000111000011101010111111110101001100000000,
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
      64'b1111111110100111100010101010001011001111111111111011111000110101,
      64'b0011001101010110110001000011001011110101101101111101000011000000,
      64'b1101011101111111000000010010001000011100010101011011110001111000,
      64'b1110000001010000101111011000111000010001100101011001001000111001,
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b1111111011100111000010000100111000001101111010000101110100001110,
      64'b1111100000011111100100110111110000010111111111000001011101101000,
      64'b0010101101100100111010000010001101001000100110011011011000101010,
      64'b1001001011100100010111011100101111001000101100000011101110011110,
      1'b1
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110000011001100001011010010100011000100101111011101111011000111,
      64'b0110111001111000001011010011010110101010100011100001100110010110,
      64'b1100000110100001011110111000001101110110111100101101010100111100,
      64'b1000011010111011011111111101111000110101110101111001000111110110,
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
      64'b1111011011101110000001111110011110101100110110111110110101111010,
      64'b0001110100101011010000001001011101110101010001100000011001110000,
      64'b1011011111100101011001010100000011011010100010100111010011001110,
      64'b1101010001111011000000011101010110101100101101000101101001111000,
      1'b0
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101000000101000011010000100110000101101101011011011010010100110,
      64'b1001000001101100010110011110011100111011111001111010000000000101,
      64'b0110110001101100100010110011010011110100001010010011101011100111,
      64'b1001110011001110100110001101101100001001001000001100000000001110,
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
      64'b0110001110001101001010100011100000110000010100000100001000000010,
      64'b0011010110000001000000111000001001111010001100111101010100011101,
      64'b0110011001110101100001001001100101000001111110100000111110101010,
      64'b1011101101000101100011000110111110001011110100111100111001110000,
      1'b1
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
