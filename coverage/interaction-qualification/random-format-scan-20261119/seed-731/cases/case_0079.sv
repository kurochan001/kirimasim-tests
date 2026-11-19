/*
:name: random_cross_case_0079
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0079;
  typedef bit signed [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111001000001011010100111110010111101011101101100111010000000001,
      64'b0110001011101111110011100010100000110001000011100111001101110110,
      64'b1011100000011110011011011100110100000101011101000100000110100111,
      64'b1111110110010100110001011010000011101100111011100000111011100101
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101101011011000110010111101011101110011011111111100101111101001,
      64'b0111101010111000100110010001110000011101100111110000010001111100,
      64'b0111001001100111100110000000101101001011010011011011000001011110,
      64'b1001100100101100101111100000000011110011100100110110101000001111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010001100001010111110011001100010000000001100001110111000000100,
      64'b0100110000101110101011011011010100110011101100101100001100110100,
      64'b1100100000010100010010001101001101101000000101000000000101100011,
      64'b1000111000000011010111100000100111100010010110110100111000100100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001111001010000101110101101111010110111000111111110000001111000,
      64'b1000011000010110001100110010110010011100001111010011001100101001,
      64'b0111000010100111011100011110010001110111010011111100100100011111,
      64'b0101110101000110000110000110110111100100000101100011100000001111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001011101000010101010110010110100000111111000110011111010110101,
      64'b1101111010000111101111101101110100000001100011011001110111001011,
      64'b1000101111111000001111000010000011100011100001111010001001001010,
      64'b0010101011001001011100001100111111011001110010010000011101100001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0011110111000000110110001000010111011000000100011000111110010100,
      64'b1100101000010011111011100001000011100001000101011110101011000010,
      64'b0101111111110111111101000011000100110010111000101000111011010000,
      64'b1011011001100111101101100110111010001011101111101110101000111110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010000000110000110011110111011011011110111100011010101101110001,
      64'b0000010111000011000000110111000001101111111100101011111100010010,
      64'b1101111000101001111110101000110010111000010101110010010110110101,
      64'b0111100111010110001110101011100110001101101101000100111001110011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v7_input=%b", source);
    $display("v7_text=%s length=%0d", text, text.len());
    $display("v7_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    $display("widths=%0d,%0d", $bits(source), $bits(parsed));
    $finish;
  end
endmodule
