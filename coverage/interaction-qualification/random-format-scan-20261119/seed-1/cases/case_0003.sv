/*
:name: random_cross_case_0003
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0003;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0001101010111011100010111010001101111110000010101011001011101101,
      64'b0011000110110001110000100111111010010111011001101001100111001100,
      64'b0110111011010101110100011011111111100101100001010101010100101111,
      64'b1010110010010101010010101011010110010010110010010011010101111101
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110011011111110110000001000011011011111001000101001011001010000,
      64'b1001110010110100011100011010010101010011010010011101101001001000,
      64'b0000010001100111001110110111010101111111111100101110001101000001,
      64'b1000000100001101001011100011000001001011110010110110101100100010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001000000110111000101011100100011111100101011110100101001011010,
      64'b1100111110100110110011110011111001010011111001101101000010010011,
      64'b1101101110000111100001110010110100110011011010110001101001000101,
      64'b0010100000101110111000001011110000000100101000011011110111100100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110000100010101011101011100001011010110011100111001001111010110,
      64'b0001100010101110000000010011111010101100101010010001011001111001,
      64'b0100010000111011101010101100010100110110100010010001111011101011,
      64'b0110110111100010101100110011101101010110110011101111100011101100
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111110001001010010001000111111011000100100110000111001011000110,
      64'b0111110000001000000110111011011110001000110010011101101010001010,
      64'b1010111111100110011100111111011011010110011100110000100000111001,
      64'b1110000111100100100001010101011111101010000110010000101100101010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110100100110110011111101101100100101010101000110011000000001011,
      64'b0010101101110001000100110100001100100010000011010110011100101011,
      64'b0001010110101101100110101001110100001010010101111010111100110101,
      64'b1011100110111000000101100011010100010000101110001111111000100010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101111000111100010100110110110001000001010110101100010000000000,
      64'b1101011101010100011100001000000010000001100000011110100001001101,
      64'b1001100110100111010010010010010001010101000011010100000011011101,
      64'b1100001001010101011100000011010101000100100111000100110010100010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100011110001111111011000100010110011010100111101001100101001100,
      64'b1111000110101001101001100101100011011110000011110011100110100111,
      64'b0011110000110101011000010010111001001010100011010001010111011000,
      64'b0001110100101001011001011000100001010111000111001110111011101110
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
