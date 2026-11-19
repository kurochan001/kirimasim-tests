/*
:name: random_cross_case_0020
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0020;
  typedef bit unsigned [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0010011010100110001101100100010000011000001000001111011101111010,
      64'b1000100001100110011110110010000011000011011111001001110100100001,
      64'b0101100000010100011101001000110011100000011010010011010100000000,
      63'b010000010110111111001100100011110001101001001011010111000100010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001010001000100100101100111011110111101011001100111101101010011,
      64'b0000110100110111001000010001011111100011110000010001100001011000,
      64'b0010010110011011000100010011011101100000101011011001110000011010,
      63'b100001010101111000100001101100111010111001011011011100001010111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011000110001011110100100000111100011010101000101010010100000101,
      64'b1111001001011001100111001100111111011010111100101110010010001001,
      64'b1001010101001111110111010100100010010010000101100100101100011010,
      63'b010111011111000111010000011110010110011100100001001000111000100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100011001111000111101000110001111010100001000011110011110011100,
      64'b1011010101111110101111001110110000011000110010110010101010001010,
      64'b1111110000000111100011100111100100000100110000000101101001110011,
      63'b100110000010001101011111010010111111100011001010110011101001000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010101100111100111101010100111010011001010111111101111100001011,
      64'b1100011001111000110110000000011000110001110110011101101000010010,
      64'b1011101000000011001111101011011010110110100100010111001100011100,
      63'b100001101010011111011000010101111100101110011000010010011101001
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011010101001100011100010011011100001010010010111001000010011011,
      64'b0110111001000000100010011011000100111111101100011000011101010111,
      64'b0110101101001011100001111011111100001001010010001111111001101111,
      63'b001011100110011101110111110111000101010111100100000111000110010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100111100001011111010110101010011000111111101101100101010110110,
      64'b1011010101010100110011011111001011000001111110001010110110100100,
      64'b0101100101111101010100000100000010001011000110000010001010000101,
      63'b100101000111011100100011100100110110110111110000110101010001101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v7_input=%b", source);
    $display("v7_text=%s length=%0d", text, text.len());
    $display("v7_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    $display("widths=%0d,%0d", $bits(source), $bits(parsed));
    $finish;
  end
endmodule
