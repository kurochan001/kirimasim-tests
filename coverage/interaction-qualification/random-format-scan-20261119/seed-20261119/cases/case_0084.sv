/*
:name: random_cross_case_0084
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0084;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110001000001010110100011100000101000101100000110001001111011011,
      64'b1110010101001001011011111000111100001110010110001101001001110110,
      64'b0000000110000111011001100111100101000011001001000101111100111111,
      64'b1101101000011001001000110101010010111110100010000111110011100101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110010011010110010011110011110000100010101000000100111100000101,
      64'b1101101110000011110110100000001110110011011000100011000100010001,
      64'b0000111010110110000011101000001010000001011011111110100110001010,
      64'b0110001001110001011101110010100001010100100111001010111000101110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101011000011100101111111010110010111001110110001100101000000000,
      64'b0111010101011100011010111011100001110010110100000100100101010001,
      64'b1011111110100111111101001100001001010111011001101011001011000000,
      64'b0001101010000110010100101111111001100110011000001110001101011100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101010100100011000101001110101100000110110101000000010010111011,
      64'b1110100110000001110000011001110111100110110111000000110001101010,
      64'b1101000100001011101000010110100010110110100111100010110010011100,
      64'b0000110011011100011111111101001111111111110100100001011000011101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011110011011011111010101000011110011001101010100001110101001000,
      64'b0101011110000000000011010000011111001110101011101110000011000101,
      64'b1111110001011001000010110011001000011000001110110000101000010010,
      64'b1111000100001111100110010010100001010011100011111011001010100110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0100010100001111110000001001010000010010101010101101010110101101,
      64'b0110111011011110010100001001011100010001100101101101101000110010,
      64'b0110111000101111100011111011010110000111001110101111101100001110,
      64'b0110111110010011110110100110011110110000010110111011111000111110
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
