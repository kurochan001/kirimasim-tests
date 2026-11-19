/*
:name: random_cross_case_0039
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0039;
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      63'b111111111111111111111111111111111111111111111111111111111111111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101111010101111111011101000110010101110011010100110100011100000,
      64'b1110100001111010111000011000000011001000000101001010111100111010,
      64'b0110110011100111110111001101110100001101111100001001001101111000,
      63'b000100010100101010000011000001101011011100110011010111001010111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100111110100101001011010011110100100110110000100101011000000110,
      64'b0110001010100100010101001110001011010101010111100111110101100110,
      64'b1000101111011000001010001111100011111100100101110010011001110001,
      63'b001011000001110011100001000000110011111011111111110101111010000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010111110001110101011110111011100101001101011010011001011001101,
      64'b0111101110110101101011011000101101101010000111011100001000110100,
      64'b1010100010111101100010010001101010100110010011100110001100111111,
      63'b111000010000111110111100111100000000100001010100110110101111110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000010011101011010001001001101101111100000100100111010000011011,
      64'b1001001011010111000011001110011010001011000111111011111000001010,
      64'b0101011110101011100111010100110001101100010011101011111101111100,
      63'b001110010100101110100100111100011100111111010110010111101100111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111000000101011010000110000010011000111000111011111011100100110,
      64'b1001100101100110111111010000101101010001000000110100110100011011,
      64'b1101001100000010111111001101011110010100010011100010100000000110,
      63'b111010111000011110010110110011000001101011011100011101011010010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000101110011110000011000101010011100101100010001000011000111110,
      64'b0101111011110011001111110010110110100000110100110010010000010111,
      64'b1110110000111110001111001000011111011011001001111100100100001000,
      63'b011111001010100001100110111010001100001110000101110101010100010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010111011110110000110010110011000111101110101101101111001001001,
      64'b1011001110011001010101100011000101001111011110110000011010001101,
      64'b1011101100000000000000100010011010011101000010110111110101000111,
      63'b000100010110010110111001001101101000010000001111100001111011011
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
