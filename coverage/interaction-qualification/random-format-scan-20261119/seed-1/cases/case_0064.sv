/*
:name: random_cross_case_0064
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0064;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0100101001000000100001000011100111100100011111111100101111110000,
      64'b1001001110001010010110011011010101001111000100110100011010100000,
      64'b1011110111011101000100110101011010100001110100110010111010110111,
      64'b1110110110110010101010000011110011100110011010101100010100011011,
      1'b0
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
      64'b0001101010100101100100110011001110111111001011110010110000111110,
      64'b1110001100110100000111000010100100001001101001010001001101010010,
      64'b0010000101001110101010010101010000001001001111110111001001110011,
      64'b0000011111010100110010110001011110110001111000110011100111100111,
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
      64'b1101011011010111100000011110110101011000000011110100001000001000,
      64'b0110101000110001111001101011001000000000100011000001110100100010,
      64'b1110101111111001110001011011011110101011001001100010000111000110,
      64'b1010001001101010101100101101011010000101001001110100010111101010,
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
      64'b0110000010001010100010010010001100110110001110011100100110111011,
      64'b1011011100110111000010000000000101110100001100100010010101100000,
      64'b0110111110010010000101101011100001101000011001011010111101110011,
      64'b0011011100111001001110110010110111100100011001110101111101011111,
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
      64'b0111000111000111100100101110100100100101000001011010011011001001,
      64'b0011001000011111010001011010100001101110010101010010111111100110,
      64'b0011011101011101111100101011110111011110111101001100101100011111,
      64'b1001100011000111001000100110100101100001010011001001100100101111,
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b1110101101111011110110001100101110001111110000011100100011001011,
      64'b0011000011100101101010001011011011011010010001111011011010011011,
      64'b1011011011110110111111010111101011001000110000100111011101001010,
      64'b1010111011000011110001011101101101110100111111001101111111111101,
      1'b1
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
      64'b1110110111110100100110011111010010011101010101100010000110001010,
      64'b0111111111001101000001100100011010001110011011000111000111000010,
      64'b0001100110111100101011101011111001001101110101000000110100000011,
      64'b0011011110000100110011000111110110000110101001011101110010111011,
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
