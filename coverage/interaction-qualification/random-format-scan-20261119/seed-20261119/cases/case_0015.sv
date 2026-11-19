/*
:name: random_cross_case_0015
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0015;
  typedef bit unsigned [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1110101000001001101111011000001000000100110111110110110011110100,
      64'b1011001100111011110111001111011101000000000001101101111110101101,
      64'b1101101101011001011000101000110100110001000111100011110000010110,
      63'b001011011100011001010100010011010001100011110000101110001111100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100101101010010011100000010110000111101110111100111101000101111,
      64'b0110110001110100100110111101111000111111001000111001000011011000,
      64'b1110100010110101110100101100001100111001100000111001001001100000,
      63'b100001000100100100110100000010001111100010011101111010101001110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110101001001101010000100000001010011110011001111100001010111100,
      64'b1010011101101100001010001100001110100111100000011110100100011101,
      64'b1100001010011010010001111110011111001111101100010100010111111101,
      63'b111111010011011100111111010000101111110110101101010110101110101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010100001001010010100101101111011100000100110101000001101000110,
      64'b1110010010100101010101111100110000110001010011100001010001110110,
      64'b0000011000000110100100110111101001010100111000010010010011010000,
      63'b111110111110010000111101110001000011010111100001111100111111100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110011100110011111111100000010000010100011010000100110001001010,
      64'b0100011101111011110101100001001101111000110000010110110100000111,
      64'b1000101110101011001111011010001000110100011101000101011000100100,
      63'b010111110100001100011011110001100101001000011011000001111011101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100010101100010010101011111000111110101101011001001001100011101,
      64'b1011011011000110011001000000010010110000110000001001100110010110,
      64'b0110010000111111011010000010101011000010110111010011000111000011,
      63'b000000010111100001010000110110100101101111000101100110010110111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010101010101100110001110110000001000001110011011000000000001110,
      64'b1010000101001100011011111111110110100010101000100010011111110000,
      64'b0111001001101101000010101001110111110000001110101100101110001010,
      63'b110011110100000110001001001010101100010100010011111110101111101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111111010101100000100100001010010001000001100001100101110111111,
      64'b0010001111001111011101111100111101110100001000110101011000101110,
      64'b0111010010000111101111011000101111000101001000000011010110101010,
      63'b110001110010101011111100011000011111110100111000000001011110101
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
