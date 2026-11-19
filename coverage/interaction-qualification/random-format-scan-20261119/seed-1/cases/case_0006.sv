/*
:name: random_cross_case_0006
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0006;
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
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100011100011010010110110001000100000000101110110110000011010100,
      64'b0011001110101101101011100111011001001110111100001010000011111001,
      64'b1011011111011101111011101111010110111001101011010010000001010010,
      63'b111100000000101100001111111000001111110010001100101101100011001
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010011001001001110000011011000110001101011010110100001110001100,
      64'b0101101111110000001000010111001001011000101100110011000010110011,
      64'b0101010010011011010100000100010111100110000000010011010010111001,
      63'b000001001011111100001010100001000010011101111010100100010001110
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101010110101110001100000101101100000111010110011111011011111101,
      64'b0110101100101100100000111010010000110110101110001010110110100110,
      64'b1001110001111010100110100001111010100011101110101011101010111001,
      63'b101110110010100011001100101100011010010010100010001110000111000
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000100000100001011010110110010101110001111111000101111010010111,
      64'b1101001000101010101001110101001100010111010010101101101001101000,
      64'b0100100010001010010111011001111001101001110110011110010111011011,
      63'b110010011001101011000000111010100100000010101010010111101011111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101011100111001010101000011101100011011000111000111011000100111,
      64'b1101000001110110011101010110001101011000001010100110000011101101,
      64'b1001101110010011000011001100110100111111001111110000000110100001,
      63'b110011100110000110010110010100011010010001011110000001011110011
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101110010110010100001001111100101101101111111010111100001110100,
      64'b0001100011011100101100101110011001010000110101111101111001010011,
      64'b0001001100110010001100010100111011011101100000101011101001110000,
      63'b100110010000110011100000110001000101101100110111000111010111111
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110111000011111101101101010110110011101110100110100100111111010,
      64'b1110010010110101001101001011011111101101010000001110101000000001,
      64'b0101110100111001000010101100011000100000111110101110010110101011,
      63'b100011100011100010111001111000101000000101010011000000010111101
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
