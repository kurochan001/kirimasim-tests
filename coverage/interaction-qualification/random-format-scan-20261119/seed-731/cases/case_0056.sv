/*
:name: random_cross_case_0056
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0056;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1110110111110010001011101000000011011100010001100101110111000000,
      64'b1111001001011110110111000110100011111101001001001000000101001110,
      64'b1101001010010010101011110000110001000001001011101000111100011101,
      64'b0011000010101101100111111111111010000101110010010000110001101110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0100010100010100010001011101011001000110101010000011011010000100,
      64'b1011101111000001101110101110011001101001100101000000011111010100,
      64'b0010111011100010101100010001001111111110010111010000110010110111,
      64'b1110100010110011101100100010100100100001100110100110001110010110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000101010111000010110101101110101111110001011000110000001000011,
      64'b1110000000010100010100101010101001010010010010110101101010111110,
      64'b0001111101000101010010011111101001011101011111110001110101100001,
      64'b1100101001000100100000110010010101110000000100101011011101010111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000110101010110011000110010000000001001100101010111001110000110,
      64'b0100100000000001000100111110111010001110011001000111110001110100,
      64'b0000111110000000000000000110010010011000101100000010110101111111,
      64'b0010110011100010111100101000101001011110110010001011011100111100
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111010100011110110100001011010110011100111110010101000000111110,
      64'b0101111100111100001001001111100111101101110011001100111001011001,
      64'b1011100000110000011011101101111111110001001011111011001010110110,
      64'b1111110010011110101100111000100111110011001001000010110100101010
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1111101000001101001001111111001100000011011101001001110000100011,
      64'b1110000000101110100100011011011100111100101100110010000001100100,
      64'b0101001100001000110110101011100001110010001110111111101010010110,
      64'b1110111100101111110100011010110111100011101000010000110001000111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000111001100010001000000100110111110011001011010011110111101011,
      64'b0110001000000010000101001111101001001001100001101100000000101101,
      64'b1011000100011011011011101011110010100111110010011111110010110001,
      64'b0010100100111011010011100100101111110001100101010111110101101111
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
