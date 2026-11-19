/*
:name: random_cross_case_0072
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0072;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1100111110101100010111111111010010100101001010101001101100001000,
      64'b0010000100101111001101011111101100011111011001101011001101011110,
      64'b0000011100101010010111110101100100000111011101101000001101101101,
      64'b1010100101011110001010011001110111101101011111110001111100100110
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
      64'b1110100011001001110111101111010000001101101001000101101001001010,
      64'b0110110010000101000001001001011010111011001101100110101010110111,
      64'b0111111110110001010100111100111100110001000111110000101110110010,
      64'b0001111110010101101100110110101100100011000011010110111110010110
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
      64'b1011110011010011101001001001110101111001100111001111110001110110,
      64'b0011000100101101000110101011100110000100001000000101101011101000,
      64'b0010100000001110101001100010101010111001101110010010101101010110,
      64'b1001101101000001111010101001011100011011110100100010101001001101
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
      64'b1111000011001110111110100001011010011100000110010010000000100100,
      64'b1011111010011110001101101110100110101101001011100010101010110110,
      64'b1000000100001110111010010111111111001110001010010001111010101010,
      64'b0110011010101111101100110110111100110101001010001000101110100011
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
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
      64'b0110001000100001101010010001101011011101100000110010111101100001,
      64'b1110000100110010000000001110110110011010100010010010101011111100,
      64'b1010100101101011101110001110110001111011110000100010110110010100,
      64'b0101010100010000111000101101001001111001101011100010010100101100
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
      64'b1100110101011110100010110100100001111011000110011110010000110110,
      64'b1000001100100110100100010111010011100110010110001001111110010001,
      64'b1011000010111101101010101100101000001011001101100010101000110101,
      64'b0111001101011100101001001010010011101011000001010111011011101101
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
      64'b0011001110001000101100110111111100100010101101011100101101111000,
      64'b1111001101000101000111001101110011010100011010001110101010011001,
      64'b1001111000111011100101001101011110000100111100110000010011011011,
      64'b1100100111000101000001010110001011011100010111111100001000001101
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
