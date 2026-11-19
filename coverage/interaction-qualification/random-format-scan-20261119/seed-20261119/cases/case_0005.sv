/*
:name: random_cross_case_0005
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0005;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0100001000011100011000110100010100101100111010111101000000110101,
      64'b0010101110100001000001010001011100110111101101111101101110000001,
      64'b1110011001001000011101100011010111010010011011111101100010100111,
      64'b1010111101001110010111011000100111001100011000101000101010001110
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
      64'b1111010101011111011111000100110101011110111011000000010000011011,
      64'b0110001011001100011000111011000010010111101101011101011110000101,
      64'b1001001101000010101010101011100001010001100000111101111110100111,
      64'b1011101101010000110101100000100011110011010000100100100011010011
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
      64'b0011001010110111110110001001011001010111010110010100010010010111,
      64'b1110110001000000000101001001110110111000010010100111001001101000,
      64'b1010111110001000001100011001011010100101001001111010111100000100,
      64'b1110000101000100000010010101100000111111010011011010001111100100
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
      64'b0011101110111010100010101000101011000101011111100100101011110100,
      64'b0111010011011010110010001110010001011100100000101001111100000010,
      64'b1001111011100001010000101000001010000001000111010101010011101101,
      64'b1100100011101101100101100110011001110010000101011001111100001100
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
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
      64'b1111010001001110000101111010101010011010011000010110100111100010,
      64'b0101011000001111010101010010010101110001111101000101000010111101,
      64'b1000101110110010000111100110000010000111110010100000011011001101,
      64'b1110011000100110010101110001000010011111010100000010000000010001
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
      64'b1111010000011110000001111110000101000010100011010110011000001100,
      64'b0011111001111001000111011001010000101001010010101000111110110010,
      64'b1101111010011100111010011011010100111100001011011001100000110110,
      64'b1001110101101001110011000101111110010100101011000111001100010100
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
      64'b1000011000010000001011010100000111101010101011000111000101011101,
      64'b1101011001010011100010010001000110010011000001101000000001011100,
      64'b1101101101011111010000111010100001101100110000011101010000001111,
      64'b1000111001110000110101101100100000010111110101011000100111101010
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
