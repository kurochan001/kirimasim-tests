/*
:name: random_cross_case_0038
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0038;
  typedef bit signed [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111101000100010110010000011100110000101110001001011111100010000,
      64'b1110101010011101110100000101111101110111000110001101010000100000,
      64'b1011100010011010001110101000011010010001001111000110001000010110,
      64'b0001010010100111111110101011101010011000111111010101101010100010,
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
      64'b0100100110111000110000001011101100000001000100101000000011011100,
      64'b0011110100111000100101000001011000111110110001011111111110010010,
      64'b0100100011001101010000001100011100010110001100101100100011011100,
      64'b0110011101110011001111110100111101111100001001000100000100001001,
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
      64'b0010100001001011110100101011001110001111110010011010010000100101,
      64'b1011101110100011010000000001011101111111001011100010100111101100,
      64'b1011001100111101101101010000101101111110011010001110110001010001,
      64'b1001101010101011110101010010011111000001001110001010011000010011,
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
      64'b1101111011101010100101110100000111110100101101001111100000100110,
      64'b0110011100011000110110101011011100010111000110011110110000111101,
      64'b0001000011011001100010111000010110101010001110111001101010001101,
      64'b1001010110101011111000111001001001111110111001101100111010100100,
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
      64'b0100011010101100000000001000000101000001010101100110011001110100,
      64'b0011101010011111001111111111010110111011111010011011100110001110,
      64'b0011011010110101010001100100110011011010011100011100100110000000,
      64'b0100011011110110001000111111100000011101111111000000000100000000,
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
      64'b0110010011001100110010100000001101101011110111000100010100010111,
      64'b1100101111000111111101011100100010100111100001110110010101101010,
      64'b0111101001000010111110000001100111000000111011101010100011111011,
      64'b1100111011001100000110000110101111000010100011001111000110000000,
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
      64'b0000111100111101011011011110110110101011100101000110010100101101,
      64'b0111110110011011110110110110011101101000000111100111001101001010,
      64'b1000000011010010111110100000111101010111010100110000000110101110,
      64'b0001001111001001110010110011111001010110001101001000011100100001,
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
