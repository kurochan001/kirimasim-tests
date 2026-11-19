/*
:name: random_cross_case_0023
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0023;
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111010100000111001111001111111101010101110011101001101101010001,
      64'b1111101001010011000111100010011011110101100010110011111011000110,
      64'b0000000011110000110000001110010110001101000000111100111010111110,
      63'b110000100001111000010111101111011101111011100101010000010100011
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001010101101101000000100100110111010110001010001111111000000110,
      64'b1111111111001010000101011011110011010001110101100000110001001110,
      64'b1101010111000000000010110001111110011101000000101110110101110100,
      63'b110010100011111100100010001011110011110110001000111010101100100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
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
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110100110010111111111110001011011100111001100001000001101111011,
      64'b1101111000100100011000111000100010011001000010011111111110100011,
      64'b1011010001000010111100001001100111000001001111110111110010111001,
      63'b100000010000010100001011001111100001010111011101101111110110010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000001101010010001100001001100101010100000001010010100010011110,
      64'b0010110111100000100011000011101100110011011011101100100000111100,
      64'b1101111110010110010111100100110000110010110101000011000101000101,
      63'b111100011111001100010101110110100001101100001100100110100111100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000111000010011101100010011111010101011010000111110101101100100,
      64'b1001000100111110010111011101101000001101111101110101100010000001,
      64'b1100111110010010110001000111110110001100110110110010110101110110,
      63'b110010100101010111010010001111000111011001010100000100111101010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110111100001000001010011101001101001101001100001110000111010001,
      64'b0001011000110010000000110000000001101101111010110101001101001101,
      64'b1110110100110101000111010111001010101011101111101100001100000100,
      63'b001001001100011110000000010111000011011011010010111110111110011
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110101010010011001000011000000100110100100001110001001010001111,
      64'b0000010101111110010001001111111101011111010100011100101010111011,
      64'b0101001110011111000000110010101010010111100100111010111001010011,
      63'b111010111011100111011110111001101001110000001001111101001111101
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
