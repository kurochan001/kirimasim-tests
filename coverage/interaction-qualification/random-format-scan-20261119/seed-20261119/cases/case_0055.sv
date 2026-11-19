/*
:name: random_cross_case_0055
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0055;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1001111010010010011111000010011100101110100110010101111100011110,
      64'b0111000100110011001001100000110001011110000011111010001111100101,
      64'b1101000110001001101100000100000001001010011110011001111010001001,
      64'b0101000110110011010000111010011010001101110101110111011100001000,
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
      64'b0000010011001101000000111000001110000100100111001010011100111001,
      64'b0100111100111010100010010000001011100111111001111000110011010010,
      64'b1011010010111100001001101111011010000110010011100110011100111011,
      64'b0100010011011101010111100010011000010001001001001101100100000000,
      1'b1
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
      64'b1011100001100011111000000101110001100110001011011001111010010000,
      64'b0011010000011100001000010111010000011110000101001110010100010101,
      64'b1010100100000101011110110101100001001010011001010010110100001101,
      64'b1111110001010111011101011011000000001010010011100100100110111110,
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
      64'b1110001101000111110011011100111101001001001111111100100001010000,
      64'b1001110111101001000110110110010110110101001110100000100111110011,
      64'b0100000100111000100100010001100111110001010001010001111101110110,
      64'b0110100010110110111111111100011000011000110100000100100001110001,
      1'b0
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
      64'b1010010101011010101010001011000101100001111110100110100110001010,
      64'b0111011001011000010100110011100010111011101101110011010100001101,
      64'b0101111100110110011110101100001111001010101011001101101110001010,
      64'b0101001011010110101111010010110011100000000010011011001100010001,
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
      64'b0111111010010000000101101111100101110001111010000010110000010100,
      64'b0100001011111011110111100101001000011000101111000010110011100110,
      64'b1001010010000111000010100000111010110100111100001110100100000111,
      64'b0100011110000101110110111011111011101100010110100101100011101100,
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
      64'b0010001001100001011011000111000110010010100100101010000001100110,
      64'b0000001110101111001001100010100101011000101000010100001110000010,
      64'b0000011100000000100000001010010010111100111100010100100001110100,
      64'b1010100011110100010011101111101101011100011000110010011000100010,
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
      64'b1111100001011101111111100001011010011010111010101111010101110001,
      64'b1010001111001101101101111000110110101010000101000111011000111110,
      64'b0001100101010011010011100111111101111011011011100100000010101001,
      64'b0100111100111000100001110001111000110100110000110111110010111100,
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
