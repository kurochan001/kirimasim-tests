/*
:name: random_cross_case_0093
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0093;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0001101100110011101101001011010101010101001101110001111000101010,
      64'b1000110110111000110101101011100010011101011111100100111011100110,
      64'b0011101100011111000000011110110110110110101111001101000010111010,
      64'b1111110001001011101111010011000110000000011110110100010001111110,
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
      64'b0111111111001110011110010111001011000010111101001100111001001111,
      64'b0110010101011000001010110110101111110110010100111000000010100110,
      64'b0100100011111101010111000010100011000001011000000000010111100001,
      64'b0111000110101111101110001100101010111001010100111110010010111010,
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
      64'b0100110111011100110011001000011010111110011100100001100010111110,
      64'b1101101111111001001011001101011111011011100000010000000100001000,
      64'b0001000011010110100110100001101011011010101101010110001111111010,
      64'b0000101010011000110010011011001101010101000100100011111001011010,
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
      64'b0010100000000111101100100111001110111000000110011111010010001100,
      64'b1100011011100101000011010010001111010100011011001010010101101000,
      64'b1111010011111010100010011011000111001111011011010000001011110010,
      64'b1001100100001001010111001110000010011101011001000111011100011101,
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
      64'b0011100000100100101010010011100011101001000010101000010011000101,
      64'b1101100100011010110000101101101010010001101011000010100011011010,
      64'b1101100100101010000011100111000101100011100011100100010010110100,
      64'b0000010101010100101100011101101110011101000100100011101011011101,
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
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
      64'b0000010010101111001011101010111010010000000000101000100000001011,
      64'b1100001101011111000010110100011001010011101011100010111101000010,
      64'b0011010000010000100100100100000101011101001011110000111111101100,
      64'b1001000010000110101110011011110111111000100000010011001111011011,
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
      64'b0001110110000010111010001011101110111000010000100010011001111110,
      64'b0100001010001111100000101101100001100110100000100111100000001100,
      64'b1101011001010100001100111100000100000100110001101110010110011110,
      64'b0100000111101001110011110011100111111000100011110000001111100000,
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
