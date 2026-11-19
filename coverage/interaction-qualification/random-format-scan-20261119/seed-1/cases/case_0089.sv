/*
:name: random_cross_case_0089
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0089;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b0001010000010100000011000100010110110111110001110001101010110000,
      64'b0000001111111111010000100011111101110001101101000100010100011000,
      64'b0001011011001110110010011100011001111001000101010000111100010000,
      64'b1001100111111011101100101101110011101101001100011001010100001110,
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
      64'b0101101010001010000100000011011000101101110001100101010100100011,
      64'b1100000001000000110001011000001011001111001100100110000010110110,
      64'b0011100100101100001010100101001100000110101000000000010011011011,
      64'b0010100100001001110011010110100001111001110111011001000110000000,
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
      64'b0000011010111111011101100101000011000010110011011010100111100000,
      64'b1100111011011001000111111110000111110011000010101010101111101111,
      64'b1111000001101010010101010010110101111000111011110100011000101110,
      64'b1100010110001110110010101011001111111100010001001010110000110100,
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b1111011111010000011001111000101010100111001010001110010001111000,
      64'b1101010111010000001001011011010000001110010010000111111100011001,
      64'b0111100001000111101010100100111100101000100001011111101000011001,
      64'b1100000111001001100010001001110110011101011010010110100000111100,
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
      64'b1000000010001011110010110101100101111010010110010101100001010000,
      64'b0000001001010101101101111110000100001110101100011101111110101111,
      64'b0010000111101111001010110110011000110101101110110111111111011000,
      64'b1101000111101001001110110100011010100010000110100100111101010011,
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
      64'b0000001111000101011011010010010100000100011011010101000101110110,
      64'b1000010101101011000111110001000100010100010111000110000110001101,
      64'b0010100111100011100010000001000100000111010001111000111011100010,
      64'b0001011110001111111010111111001001000000001111011101100110100000,
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
