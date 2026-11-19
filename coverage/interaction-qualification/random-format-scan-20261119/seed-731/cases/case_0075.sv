/*
:name: random_cross_case_0075
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0075;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1010111110011110100111000111111101000001110111110000011100010111,
      64'b1011011010111111100100000000000110010111000000110110001000010001,
      64'b1100110111010110110010101010100111001111000001011101000000000101,
      64'b1110010001101000000000001111000100101000000110001000100001011110,
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
      64'b1010001111000101010111101011100110011000111010011010100110111000,
      64'b0111000001010111011001110010101010011001100011110100111101011111,
      64'b0110011011100010001111101100001000111111111000010001010011110100,
      64'b0100101101011101110101100100101001001110100110010000110100101010,
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
      64'b0001001000000110110111010011110001000110011011000011000001001010,
      64'b0101110001100001001100001101100111100010110011111000010011001000,
      64'b0011010111010001010100010110010010001001010011011010110010111101,
      64'b1100000110110001111001000101100101010011000001001000110001111111,
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b1001010100100010101111000011011110111001110100001101001101001101,
      64'b1111001111000001000000000011010001001010101111010110111001101011,
      64'b1110011000101110111111001000101101010100101110011100101000110111,
      64'b0011000111110011110110100110100011001111100111001101011010011100,
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
      64'b1110011001010011111111000101100110000101110110100000101000001100,
      64'b1110110110011111110111100011011110111110100100110011001000000011,
      64'b0111111010011100011001101001001010110100011110010101110010101000,
      64'b0010000100011110010011001110001000001000101010101100101000011101,
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
      64'b0101011000001111010010010111110110010010000110010001011001000111,
      64'b0100010001001111111011100111100011101010001000110001000111000000,
      64'b0111110010100110110111011100110110010110011100000000000110110110,
      64'b0010011000000100001001111111000000000101000100100110000001000101,
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
      64'b1110001001100101011110000100110110011110111001010001011101011001,
      64'b1010010100111000010101001010110000001101111111110001110101100001,
      64'b1100101000011000101001110111000001011111100001010001101111001000,
      64'b0100001000010011100110101101101110011100110101110010110001000111,
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
