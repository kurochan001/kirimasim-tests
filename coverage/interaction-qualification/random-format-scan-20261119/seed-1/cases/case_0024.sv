/*
:name: random_cross_case_0024
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0024;
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111011010100000011011100010011010111110011111111110001000110110,
      64'b0100100100100100100100101110101000001111011010011001101001101000,
      64'b0100010101100001000010100011101010110011000011011100011100010011,
      64'b0011100001100101101110011000011000110111010010110111110011011100,
      1'b0
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101001110000001111001010111011110000011010110110100110101011010,
      64'b0110011001000101111011101000000110001101111100101100111110011100,
      64'b0011010100010010001010111100000100110000001001001011100101000010,
      64'b0000000110000111010100110111011010010011001011110100111011110110,
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
      64'b1010010011101101101011100000100101101000010100000000101010010010,
      64'b0110011000100000101000101101111111000000010000101101100010101011,
      64'b1101010101100111100000101111110000110000010000100001101110111110,
      64'b0110001000001110110100010010001010111010101110011101110110110110,
      1'b0
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000001001100111100111010110001010100000100101100101100110100111,
      64'b0111100100110000001001111010100100001101100010001011101001111101,
      64'b0110100110111011001011110011011011000011001001100011010001111011,
      64'b0111110001101101110010000001110100010011101111111011101100001011,
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
      64'b1100010011010100011001010011111100011101001110110001110111111000,
      64'b0111010011010001101111000100011011100101011111101111111010111111,
      64'b0101111000110111101100010001101111011010001100110000100100000110,
      64'b1101000100100000010011001100011101100111110010101010001000010110,
      1'b1
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111010000100000101001101100011010110110001000111110001101101100,
      64'b1111110110110111010110011101001010011111111011101100011010101111,
      64'b0110011011100100111111011010111101000101101001011101011100000010,
      64'b0000000010101110011101010001101101111110111011100110010101101101,
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
      64'b1100011101100111110101111111000111110111101111000010011001000111,
      64'b1100010010100111011001011000011011100011001100111101100001010100,
      64'b0000100110111100001111110000100110011110100111000111100111000111,
      64'b0101010011001001101000011101101100101011110101100011110001101000,
      1'b0
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001111000101010001100111000101100110110101101011101111001001110,
      64'b0001101111000010001010101000001101000001101011011101110000000010,
      64'b1000001011000010111010010001111111001010111011001101011011001000,
      64'b1011000000010110011000111000010010010110011110100100110101110001,
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
