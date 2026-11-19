/*
:name: random_cross_case_0057
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0057;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0010011111001001001011010100001010010101111010111111101001100001,
      64'b1100110100010101001100111100101000101000000110000010010000110100,
      64'b0001011010010111000101001001101110100001100001100011111010100001,
      64'b1000111010000101111000100111010010011100010010001110000011100000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101101001101000110101000110011010001101011110101010101110001001,
      64'b0110000010001010111111100011000010110010011001010000111111101101,
      64'b1100010010111010100110111011111010001111100110110010110100111011,
      64'b0101000111110100101011111111011011100000111000001111000100100101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111110001000001100100111101111011011001001110100011000100101011,
      64'b1001101010000011101000100111000010100100100001111100011001110010,
      64'b1001101100101110001110100010111001001101101100010100001010010101,
      64'b1011101011101011001100000001001111000010010001011111011111000101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000110010101100111010010110100010001100100100010111010010011010,
      64'b1000100110011100101011011011100000110110001000011011000001111010,
      64'b0110100000010000010000010100000101011110011110001011111100011010,
      64'b0101111010111111011010011100001000100110000000101100111011000111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011011011000001001000101111011110110111101111101000010000000011,
      64'b1100011110111000000100110010110001110110011010100011111010010000,
      64'b1000001111111000111000111001111110111000010111101000000001010000,
      64'b0010010110110110001000010101110111000010101110010100100011011110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010110001100000010011101101011100111010111001110001011011000111,
      64'b0110001110101100100001000001111110001100010110010101010110100000,
      64'b0101001111110101000001101010000111110000010011001000001001100110,
      64'b0001010001101010011100101001010110010100000111000001100000011011
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111010100010011100000010001011011110011010011010110010110110001,
      64'b0001011001110100011000100110011111001011010001101110000000101000,
      64'b0010001010111110010100001001100000110110010100001001100100010011,
      64'b0100001011110001011010101101010100011001000011011000101010011111
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
