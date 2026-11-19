/*
:name: random_cross_case_0063
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0063;
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1001000010100010011001001100000111101110110111110010111111011010,
      64'b0100000000001100110010101000001001110000100101111110011010001001,
      64'b0010100111000011001011110101111011111001011000011101010101111000,
      64'b1101111011011100011111100010010011000110000011011111011111001010,
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
      64'b0110111100000010101001110001011110000101000000110001001101101001,
      64'b1001001010111010001101100111100000000011000111000100101010100001,
      64'b0001111100001000100001101010100101100011111100111101101100011011,
      64'b1010000110001010111001110101011111011100101001001000110001010110,
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
      64'b0000011110011010100000010011111110010000011010010010010101011001,
      64'b0000000000101001101101100100101001000000000011110010110100010100,
      64'b1110100101010101101101010011001000001011100110011110001101111000,
      64'b1100110101101001101101101101100001101110001000100111111011000001,
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
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
      64'b1011110000010010100010011100000010110011110000100110011000101100,
      64'b0000010111011001100101100101001000011100001011000110101100000010,
      64'b1101010101010110000111111010111100110000011011010110001011001100,
      64'b1001010001001101010111101100111101100100000100001111110001010111,
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
      64'b1000100011111011101010111001011111100001100101101011011001100111,
      64'b0111100101011101011010100100011001000110101000010100011101100010,
      64'b0110010011011111011110110011100001010011100101111011001101101101,
      64'b0100000101010001101011110111100001010110000101011011000100100000,
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
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110110000101000101111100001010101011101110100001011111000110001,
      64'b1110111111010011100100100111011111000011110010011101110001011100,
      64'b0001010011000001010101110011101010011000100010000101011010000001,
      64'b1100111101010100011101101110001010110100011101010101100110010001,
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
