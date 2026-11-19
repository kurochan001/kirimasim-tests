/*
:name: random_cross_case_0083
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0083;
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0010111100100110000011001101110000111000000110011100000011010101,
      64'b1011110011101010010110110111011100110011000001010100000001110100,
      64'b1011010000001111111110011101000000100111101100001110101101100001,
      64'b0111011101010010010110011001101110101111010111000101101100110001,
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
      64'b1111001100000010101010010001110001010001100010010001110111101110,
      64'b0010000000001101010111011001011000111101001010000001101000110111,
      64'b0101100110101100011100110111101000010000111111110010101101100001,
      64'b0110011001001000011010001010111010010011011001001011001011000100,
      1'b0
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100001111100101000110011111000010100101101001110011110000011011,
      64'b0000011000110110011111100010001011001101011110001001110111011110,
      64'b1011110001011011010111101010001001001001111011110011111100100101,
      64'b1111101011111100000111101110110010110110101011011010111000101001,
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
      64'b0101100100000011100110010111100011010010111110110011110010001111,
      64'b0111000110111011111110110101101110010010100011100101101011000001,
      64'b1011100100110010110101101111100100010000110100011001110001010101,
      64'b0011111101011110110010111010100000101100000111011010011100110100,
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
      64'b1100011011010100100011100110000001010111011000001000000101111000,
      64'b0000100011111000011110000001000001100011110110010000000110011111,
      64'b0010101010100011010101011111000100011101110010001110100100010001,
      64'b0111111000011010101101111110100011110000001111011100010010100011,
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
      64'b1001110001000010010001011010000100100010100010000100010110111100,
      64'b1010011011110101010100011001010010110100011101111001010111100100,
      64'b1101000000010011000001110000011010110101110000100110100010111110,
      64'b0110010101111100110010111110100100010101110000010100011101100010,
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b0110100010101100011001000110111000111010110011001111011110010111,
      64'b1011001001001001111000111011110101011100000101101110011000000011,
      64'b0011111000110010101101100111010110100001101000000010111010110000,
      64'b1110101001100100100100100100110010001010010111100101000010000100,
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
