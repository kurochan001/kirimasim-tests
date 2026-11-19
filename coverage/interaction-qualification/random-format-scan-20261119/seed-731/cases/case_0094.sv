/*
:name: random_cross_case_0094
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0094;
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1000111110100000101111000000101010001110110001011011101101010111,
      64'b0011110001111011000011001101110111101001011011111001110111001010,
      64'b0010001101100100001010010011101000110011111011001110110110000100,
      64'b0001111001001111001001011111000000100100010101011011001101010000,
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
      64'b0010100011001010111100100010100110010011111011000011010010000001,
      64'b0110101000100011000001101100000010101001011111111110010001111100,
      64'b1011001010000011011000011011111000100110111010100101001001100010,
      64'b1001010001101010001110001000011000100001111100111000100110000110,
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
      64'b1101110011111100010000111100111100000000011110110101101010100010,
      64'b0100110000111001101001111000001110001110001001100001000101110111,
      64'b0101001110001101011111100011010100111101001100110101100101110110,
      64'b1011100000011010001010001010100101011111011110101001000110110001,
      1'b1
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
      64'b1110010101001010111101000100110111000000010001010000101100011100,
      64'b1100100010011001010011111111000011101100010111000011110001001001,
      64'b1100011101000111010100110010011111010000111011010111010111110100,
      64'b1110100100111100001000110101000000000011111100001001101101010111,
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
      64'b1011100110000101010011100000011001011001101110010011010011011010,
      64'b0011010011001100100111010000100000001000111011010001100011110011,
      64'b0011110110100110101010011111010101111011101000010000001001111100,
      64'b1001111001100000000001011000110010010101001001110101101000000000,
      1'b0
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
      64'b0100101111011100110111011001100110111101011000011110111110010111,
      64'b1011100110101010101000101111110000101011111100010100100101011010,
      64'b0110011110010000100110010010100100011000001100100011010110000010,
      64'b0110010111000011001100111111001111110111111000100111011110110010,
      1'b0
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
      64'b1011001110110101000011111111001110111011110000110111011111010110,
      64'b0101100000000000111011100000100110011001011100101000011111110110,
      64'b1110111010110101000010011100011011000101001100000000101000111110,
      64'b1011100110101010100111111010010000010000011001000110111110000010,
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
      64'b0000111000111111011111111000010000010000100000110011001001011110,
      64'b1010011110110010000010010100010111100011000111111001011010110111,
      64'b1001001001101100110010011101001101010101000100000000001100110000,
      64'b1111111010111110110000010111011001010001000111000111100100000111,
      1'b0
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
