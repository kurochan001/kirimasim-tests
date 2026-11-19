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
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111110011101001101000010110100110010010110010010100111000011010,
      64'b1101111100101001010111000100101100011001110110110111110110000111,
      64'b1110101010000110111100100100011010110100101110110001010101010001,
      63'b110101101000101000111101101111001000000111000010001100001010010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101011111001100000001000010111100001000001000100001010101010111,
      64'b0010101111101010011110011011000101110011101100001111001111001101,
      64'b0010001001011000110100011111011001100010001011110100100111110011,
      63'b000000110001100001011100000001101110101100111010100110100110000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110111011111001110110010111001110010000000110000001000011100010,
      64'b1111101110011110100010001000110110010100000011111111011000111001,
      64'b1111010111110111111010110111101010111001000101011111000111110100,
      63'b111100100000001010111110100000011100000010100100101001110111001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0101111100011001010111010010001100100110101100101001100100000100,
      64'b1111100001000010111011101001001011011110011000001111000101011010,
      64'b0111111100100010000011010000010101101010100011011000101001100100,
      63'b111011000110010011001000001110100111000111011110100010010000000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111010110110000111010101101000011001100101101100110001011100111,
      64'b0100101111010100000110010100101111100101010100110001111000010001,
      64'b1010000111000001001111101010100001110000001100111110100100000101,
      63'b011001011101011000100001111010110101011010110100100000000111001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110100010101111101101011110010000100011101100011010101011101001,
      64'b0100100110010100101110001010100001001011110010111010100010000001,
      64'b0001010110111001000100001000101101111011110001001110100111101011,
      63'b110010011111111011010001001011001101110101100101001001011101010
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1010101001100000101011100111110001000000100001111101011011110100,
      64'b0100000110110110011000111000101110010100100001101011101111110111,
      64'b1101010000001000001101111110011001000011000111010111011011001001,
      63'b100100110010111101101111101111011101110001010101111010110110000
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
