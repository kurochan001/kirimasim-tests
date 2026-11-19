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
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111100101111110100000001101011011111100010010110100101101100110,
      64'b0110001100100010100011110010010010101001001010110110101001110001,
      64'b1110111101000011100100101101001111111111011101100000001110001000,
      64'b0111010001100010000101100111111000100010011000100001010000001110,
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
      64'b0011100000001111010101110111111011011010011000101111111111001101,
      64'b0101111101100001011001111110000100010110001111110111101001001011,
      64'b0100000111000000001101111110010010100010011010101011101101110111,
      64'b0000011100000001100100001111111101000100010110101001110110010011,
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
      64'b1011001011101011001000100000001111010100010011111101001110111100,
      64'b1111110010011011001101110110100011000001010001101001000111111011,
      64'b0010100100010101110001011101000000010111010111110011110001010000,
      64'b1100101110000010000010110010000011001010111001101100111000101101,
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
      64'b0101000010101101101101001111111001100000010000011110110110111001,
      64'b0011110100011011100101100001111010110010111111111111101000101100,
      64'b0100110001100110010010010101011001000111101011001100010100110111,
      64'b0101011110110110001010000111001001111110100011001000100110011101,
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
      64'b0111001001000100010010000100010001101001001000100000010001001110,
      64'b1111110010000010000101000000110100111111001011001110111100000001,
      64'b0001001011101100010001101111111001111111000111110111101010111101,
      64'b1000100000010101110111010011010010000010001100001001010011111000,
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
      64'b0111000010001011101111100001000011000101010001100110001100001001,
      64'b1111110111111010011111001111101001100101000100000100010010000011,
      64'b0010011110010111100101111011010111101011010111111000010010101100,
      64'b1110110000110111100101010001011100100001001011001001010001111100,
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
      64'b0000010011011100101101001101011111101100111010101010010000110010,
      64'b1011101001000001010010110000001001111111110101111101011011101011,
      64'b0001000110101000110110100011000101111111101101111000001000001110,
      64'b0100000000111100010110001000000010001101101011001010100011001000,
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
      64'b1101101100000001110101111111010010010000000001000011000010111110,
      64'b0010111110000110011011000100001101000101010111111101111010000001,
      64'b1010100110110001110001011001110101110100100010110001100101010001,
      64'b0100100011101101000000001010110111011101011001001101111000101011,
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
