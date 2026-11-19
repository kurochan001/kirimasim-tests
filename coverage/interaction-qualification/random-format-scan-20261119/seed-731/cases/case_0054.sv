/*
:name: random_cross_case_0054
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0054;
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1001000101011011011111001011010110010010100110101001111010011010,
      64'b0011111101011111101011000001001010100011000101101100101011101101,
      64'b1101100011011111011001011011000000101110111000000110011101111001,
      64'b1111011111110100011011010110011000000110110100100011001110111011,
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
      64'b1010001000011110000010110000110110100101011000000101100000110011,
      64'b1110011111101010110111000000101010111011101001000111010011101011,
      64'b1100111101011111010110001000101101011001001101011110111010110100,
      64'b1100111011010011111110101001100110010100110011100111111011010001,
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
      64'b1100110001111010111001101100010010010111101110111100111001100011,
      64'b1100010100001100011100110101111011010111010100000000001111000101,
      64'b0100001111001110001010111010100010011000110011011110010101010000,
      64'b0101110011001111101010011000111101100000101000111001010110001000,
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
      64'b1111110000110100100111010110001001000111000111101000011111000110,
      64'b0110111000000010000100000011111101010010110111111110110110110011,
      64'b0100010011100010001111111110110000001001001101000110011111100000,
      64'b1010110101001000011001111010001100001011001110100110010011110001,
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
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b0001100011101100001100100101110001101011010101100100111000101110,
      64'b1100100000001010001001111110000100000010000110011000000111010010,
      64'b0011001101110110011100010000001100001111101110101111011010010110,
      64'b1100000100111110111111101101100011000011010010000001000110001100,
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
      64'b1110110000110001101011101011011001000011110100110101000000001111,
      64'b1001010000011100111010010101101110001011100101100110111001101110,
      64'b0110101100100111010110001011011100101100100111011100111101001100,
      64'b0110011101011101011011010111110001111010001011110011110011101011,
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
