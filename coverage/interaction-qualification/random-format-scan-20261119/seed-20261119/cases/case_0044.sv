/*
:name: random_cross_case_0044
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0044;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111100101110111000100001011010000010100010001111000100001010101,
      64'b1000001111100010111011100011110001000110001001001010001101011010,
      64'b0110111001011010110000010110000001010010010101011000100001000000,
      64'b0100111010110011011001110100000001011010000001000010111000101010,
      1'b1
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010100001111011110011110000111000110101010000101011101111101100,
      64'b1110011011111110000000100111100011010000100001010101001110011010,
      64'b0101011010111100100100101111011011001111110011000010110101001100,
      64'b0111011110111100000001010110101101001001100001111111111111110111,
      1'b0
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101010010010000001110001011111011101101111100100010011010100100,
      64'b1101000100010010100110111000101110010000100110001100010000100100,
      64'b1101000100100101101010110010010111001101101101000100110110100000,
      64'b1110000010011100011010101001010100010110101110100011110101011001,
      1'b0
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111111100000011010101100001010101111100001011011000111010010100,
      64'b0110011111101010000101010100101101000001001010111110011001011110,
      64'b0000111111100101101100011101001100011111100011101011100001010001,
      64'b0110110101010010101001100100010111110101000110110111100011110000,
      1'b1
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110110111111000100110101010010010110110011001100011001101100000,
      64'b0001111111000111011001001010001100110110001101110001010011111011,
      64'b0110011000101010100111100100000000110001011011010000110100010100,
      64'b0111110100111101100011010101011100011011001110111011000111011101,
      1'b1
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101000100000110011001100101011011101111100000100111110001001110,
      64'b1010000001000010000011110101001110010101100001001011011011000111,
      64'b0010011000101010101111010000111010100001100101101001010111111010,
      64'b0111000010001110110010101101010111100011010001001000010011110011,
      1'b1
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0011111100001110010010111100111101101010110000001101100110010001,
      64'b1010010000100110000101110100101110111111010000010001101101010110,
      64'b0111011100110100100100110010111001001001000011011100011100010111,
      64'b0101101010100001101000111100111001010000000110000101000101001110,
      1'b0
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110111100111001110010111010010010100100001010111110101101010010,
      64'b0011110011010011110110100011100111011100001011110100110001110010,
      64'b1011111010010101111111110111001100100010011101011100001011011101,
      64'b0110010100111010100011100010001011110010010001100011001111111101,
      1'b1
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v7_input=%b", source);
    $display("v7_text=%s length=%0d", text, text.len());
    $display("v7_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    $display("widths=%0d,%0d", $bits(source), $bits(parsed));
    $finish;
  end
endmodule
