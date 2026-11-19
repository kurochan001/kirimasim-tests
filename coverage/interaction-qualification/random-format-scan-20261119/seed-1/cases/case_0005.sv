/*
:name: random_cross_case_0005
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0005;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1101110011111101011010110011111100100101110101001001001111100001,
      64'b1111011001111010001011100110010111111101110001010100110011010001,
      64'b0110010010110111110100111010110000000001010110000100001111111100,
      64'b0000001101111101010101101101100010000101000100100100011001111111,
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
      64'b1010100010011110111010001101001101110100111010100000011110010101,
      64'b1000100000110111011100010101010110001000000011110011101011110101,
      64'b1011001100000011110110110000101010101000000110011001011001011100,
      64'b0011001000010101000110101011111000111001100101001000000101111010,
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
      64'b1111001000010011001001100100111111111101011011110001100010010110,
      64'b1110001110010010110111101100101111001111000101000100101110110000,
      64'b1110010001111111010100101110101110011011100010110111001111110101,
      64'b0010000000000010000011110000000000001110010000010001111011001111,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001100101111111111010000001111010100111010101100100110001101011,
      64'b0001101010011010011001100101011101000101010100110011100100011010,
      64'b1001011101110011110101111100101110100001001010011011101011011111,
      64'b0010110110001011101111010001110001010100101101101111110110010110,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000101110010101001000000000100100111001010101001101110001010010,
      64'b0110000001101011101100101011000001111101110111110100100111000000,
      64'b1000101101110001111100011100000000100011111100001101000111000101,
      64'b1110100011110101000000100000110000001010011010100100101010100111,
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
      64'b0001011111101001011110111100100100101001111000110000101111110101,
      64'b1000010101000001001100110100101010100111010001001011010100110010,
      64'b1111101110111001011111000111010100110001111110110011001101110000,
      64'b0001110100011100010011011000010011111000011010011111110100101110,
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
      64'b0100110001001000100000000010100101100111010111100110000011011101,
      64'b0100101000011100001100011101001011001110010000100001010110110101,
      64'b0100010110101001001011011010011110001100111010111101101000000001,
      64'b1010101011001011011011111110111100011111011101111111001110011010,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100011010001101111000001001110100100010010011111110101001001101,
      64'b1000100101000010000001110101000010110011011011010101000110110010,
      64'b1001111100110011100000010011011001100111011101010010110010000101,
      64'b1000001010011011100111011011101100011100001011100000110110011001,
      1'b1
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
