/*
:name: random_cross_case_0086
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0086;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1011101110110000011011001000001011101011010100010101110001011000,
      64'b0110110001111000111011010011011000011000101001001010101000110110,
      64'b0110000111011101110111101000111011010000100110011100010101000001,
      64'b1110011111100111111000100111101011101001111000000000010101010111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110111101100011110010111010010100011100110010111110100010111101,
      64'b1001111000010001000111001101111010101101110010101110010000100100,
      64'b1000111101001111000110110000111000000000111110101001000011100011,
      64'b0010010110001000101010100101110111110010011101001111000011011011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010111011100000010110100100111001101010101100001001011101101011,
      64'b0101111111010110010111010000110110100100101110110000000100111111,
      64'b1000111100101010101011001001011110010101001111111000100001110101,
      64'b1010110101001111011011110110101100011111110101011100100001000100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111001101111011111100110011010110100101101101101000000010111100,
      64'b1101100110000001010001011000101011011001000100001100110010110111,
      64'b1101001010010101011011101000011111011011111100010000010111100111,
      64'b0110100111110010000011110101110000010011000110100111101001000011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000101101101101110010110000011110011111011000000000100101000011,
      64'b0110010111011100110010110100000001110000110011001010100101011010,
      64'b1110111011000100001111100111010001101111100100111011100011100011,
      64'b1100011101001010011001001001101110111110011111111000000000011100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0100011100000111111110001101100101010101000000001101000000110111,
      64'b0001101100100011101010101110101111011100100110111000001101001111,
      64'b0110001100011001010000100000110101111010011001010101100111100001,
      64'b1001101010111010111000011110100001110101000011001101011011010110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010101010011110011111110111110111110100011100100010110110010101,
      64'b1100011111001001010111111000000100011000001110010011000101100000,
      64'b0000101100100100100000110100110010101000101010111010010010110000,
      64'b1111101001001010110111011011000001000011110001100010001110101111
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
