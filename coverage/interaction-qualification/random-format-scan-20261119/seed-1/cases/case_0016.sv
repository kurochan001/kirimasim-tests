/*
:name: random_cross_case_0016
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0016;
  typedef bit unsigned [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1111110110011000001111011111010010111001001000001011100001000100,
      64'b1010110101100011011000100110010101111110010010001100100001001001,
      64'b0010010111000111000000000010010101100111111001001010001001111010,
      63'b011111011010000001111000100100111001000101100001101101000101000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000000111101110010001110110110100010000011100110010001000100000,
      64'b1010111001001111101011101000000111110101101000100111000000001011,
      64'b0011001001001111010100011111101011101101110111000101001101010100,
      63'b100111010110000111111110111010001100111000011110010000100110100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1110100000100100011101001000011001000100010011011111111010000111,
      64'b0010000000100100000111010100001001110001001110000011100110011111,
      64'b0101111111011110001101011000001010000000000100000111001101010010,
      63'b010010111111010100101111101110100000111011100010100100010100101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000001
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000101110110011100000110101101111110101000010101000101100111010,
      64'b0011001011001101010001110111011110011111100110101101001000000100,
      64'b0001100110100111010111011101000100111101010010011110000101110111,
      63'b011101001011011100110011100110111110000011011110010000101111010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000011011000000101010111111111100100100011101100111011111010101,
      64'b0100001110100111111111110000010000100010001100000001100110110010,
      64'b1000010111111101001110010101001001101000100111111101111111000010,
      63'b001101101100000010000110011011010110110111100111101000010001010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
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
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001011100100001110001101110010000001011001011111101011110000010,
      64'b1101110100111010111000001110111110111001010000100101000010011111,
      64'b0000010111100000001101101011000001011000110000111001011111011001,
      63'b101011010011000011100011011110010100100101010110100111011101100
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
