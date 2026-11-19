/*
:name: random_cross_case_0043
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0043;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0001000100101111111000001101011001111011101010110011110001110101,
      64'b0000011011011010000100011011010010100011010011000001010001101011,
      64'b0111100011101100111010010000001100000110010101100100000100111101,
      64'b0100100111001000011110001010110000100110100001001000001000100000
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
      64'b1000100111100111001100001111011000100000111100110101001100101011,
      64'b0001100011001100011001011001010010000000010101011100101010000001,
      64'b1001101001001010001100011011010010001011010010100001111011110110,
      64'b0111100001000100000010000010101100010111100000111110100011010100
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
      64'b1111111101110010000010111100010011101001011011010010111000111110,
      64'b0011110111100110001001111101010101101000111111011100000010000100,
      64'b1111001110010110001101011011000110001011011111101010110001001100,
      64'b1001101000011110010110000111100010100100101001101001000101001000
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
      64'b0011010111101111001110000101110000010001001101110111011011101001,
      64'b0001110111100101110111010001100001110000000101111110100111110000,
      64'b0101000100110101110000011001000010111011110110001010101000000000,
      64'b1101010100100000101111110011010001111010010000110110010001010000
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
      64'b0001110001110000011001011110011000110010001001011111110000101111,
      64'b1110100000000101011001001100001011100010000011011100000110110010,
      64'b0001101100001111111101101010011101011010110110111011011100010010,
      64'b0001100010011110111101000010101000011010101101110001101011000011
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
      64'b0000000000000000000000000000000000000000000000000000000000000000
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
      64'b0000111111010011110111110110000010011100100000100001000010010010,
      64'b0111110011010001011010000110101101001110101011111111111001011001,
      64'b0001011101101001111101010011110100111100000001100101001111001010,
      64'b1111011011111111010101010011111011101001010000111110111100011101
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
      64'b0000011101101011010001001010110110011000011000010101000010000011,
      64'b1010101110010000001011001110000000001010011110000000110000111001,
      64'b1010000011000101101111100011011001100100010111000111010000100011,
      64'b0100110001011000110111111011011010001111011110111100001011011100
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
