/*
:name: random_cross_case_0061
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0061;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0010110010110101110010011111001001101000001100111110100111001111,
      64'b1111010011001011101100111000000111101101101110110110000100101101,
      64'b1110010010110000001100001010000100000100110101010011101100111110,
      64'b0001111010101101011111101000110001010000111111010100000110001010,
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
      64'b1111111010010100100111011000111111100100110111010001000100010001,
      64'b0101011101001010000001011111110111000000101110110010000100010000,
      64'b0011000011111100110110101011101101001011011111111101111010001111,
      64'b0111100101011010111001011010101011010010011011011000011001110101,
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
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b1101011000010110011110100000011111101100010101000000111101101110,
      64'b0010110100110010111000011000010011000011000001101101010000101111,
      64'b1101010101110001010011100000110001111000010011000010001110000100,
      64'b1111000000100100011101011001001101010010011100011011001000001000,
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
      64'b0110011110101011001001100010011111101111000110110011000101110010,
      64'b1111101100011100000100001010001100000111110111111110100110110111,
      64'b1111101101111101001110111000110101100111010001101011110100000001,
      64'b0110111011011010111001110101001110011001011101001101110011100011,
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
      64'b0011011110110111100011011000111110011111101010000010100111001011,
      64'b0111101010111011111111010101011110110111010001001000010111001011,
      64'b1101010010011010100011101111010011011100101001110001000101100000,
      64'b0001000010100101100000001000001011110000011000000110011001110110,
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
      64'b0011100000001101100100011101000101110000111100101101110100110000,
      64'b0101100111001111111110000111111010101101011001011010010100010111,
      64'b0100111111100101010000100000100001110000001001001111010011010011,
      64'b0010111100101011010010010000001100111101101001010100011001111010,
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
