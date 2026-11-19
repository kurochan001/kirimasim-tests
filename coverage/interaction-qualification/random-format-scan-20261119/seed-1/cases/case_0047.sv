/*
:name: random_cross_case_0047
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0047;
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0101000101111100101010100100101001011000010000110010001111100101,
      64'b0001000011111111101011100100001001100110001011000010010101111010,
      64'b1001101010110001101001100000010011110010111101111011110001010011,
      64'b1111110100100010010010101111100001111111011111111001001110110000,
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b0101001010011101100100110000101100111111001000011010000110111011,
      64'b1110110110110111010001110010101000011101101001010011100000100001,
      64'b0001000011011110001001001101110100000011000111000111110110111110,
      64'b1110111010111000010101001001101011000100100001001011011000100011,
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
      64'b0001111111011001110100001101000010001100100101101111100000001001,
      64'b1010101010111110110111111011010011000010000011001111101111111011,
      64'b0001100110110111001101011010100010110111110100111110101100011000,
      64'b0100111111111010000100101011110011011001110000111000000010111110,
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
      64'b1111100010100001110100000001111111010010010100111010110101001001,
      64'b1101101001111001011101110010101100101101111000101110111011001110,
      64'b0011111110001100010000010110110100010110110000011000100010110100,
      64'b0000111011010111001010000000000001001001100101111011001011100001,
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
      64'b0101000000010110010100111010010010000011000011001011010100110011,
      64'b0110000010011111101101001110100001101011001010001100110110001101,
      64'b0011010111111110111110001011101011111100011001000101001111011111,
      64'b1100011011011101110011110110010010110011001111011111110011110100,
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
      64'b0101000110111011010010010000110010110111000010111101100010101010,
      64'b0100111011100001011100011001111100110001101111101100011111110100,
      64'b0010010101101111111101100111100000000111110000110110011101111001,
      64'b1001000001001000001101010000100010110110011111111001111001000111,
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
      64'b1110101000111001110011110110110101000001000111011101010000000111,
      64'b0010000111010111001100001010010110110110000011010011101100001111,
      64'b0100110000110110111000110101101000111101010010001100001111000001,
      64'b1010001010111101110000110010110101001100100100100100100110111010,
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
