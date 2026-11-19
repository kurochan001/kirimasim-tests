/*
:name: random_cross_case_0067
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0067;
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0011100001110110000010100000110011010001100101101010001110011101,
      64'b0000111101000011110101111101010000010011010001011111111110011110,
      64'b0110101111001100010110010111010010111011101101100011110110010110,
      63'b111101111100011000110011100000011010110101011000110111110011010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010101011100101110100000110111111110100001000110101110100000011,
      64'b0000111101101100010110000100001001100100111010011010110000101100,
      64'b0111100100110011001000111100100001010110011100011110100110100000,
      63'b011001010011010111000001111010111110100001100100010010001110010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100110111101000101100110100011110101101101010101111001001111011,
      64'b1010011011010000111100110010101011110100011100110010111011000011,
      64'b1101101110011110110010100100011010011000111011011001011111001101,
      63'b011001000101111110111100110101010100100011101101111101000011101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100010100001000101110001100111111110000010101001000101101111100,
      64'b0011111100011100011100001000011010010000001011000110010100011100,
      64'b0110110100010100010110010010101111010000010001100101111000111001,
      63'b110011101110100100011011110100111000010011000100010110111110101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001010010011000001000001100000100010100110111010101101001011000,
      64'b1110100110001000010101100000011001011011011010001010101001100111,
      64'b0100110100001101010000010100000100001110011111111111010010101101,
      63'b100101100111001111111011011010000010110110001110111101111001111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011011011111100011001101101000111100000001110000111100110110011,
      64'b1001010100111010100011001011110000010110001100100101001100010111,
      64'b0001011010001000110101100011101110100011000110010110001000010110,
      63'b010001111101001001000110001010110111000100111101101100010111001
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111101001010000011000011110000011100111011010111001000110101100,
      64'b1011011110100111100001110110001101111101111000010010010100010001,
      64'b1101110100101100100000101101111101010101101110100001000101010111,
      63'b110111110110011101111011101100101010001110101010010111110000010
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
