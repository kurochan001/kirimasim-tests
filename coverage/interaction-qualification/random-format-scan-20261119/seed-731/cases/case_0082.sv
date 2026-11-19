/*
:name: random_cross_case_0082
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0082;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010000010001001110100110100001001100101101100100001000110101011,
      64'b1110010000011000111001010110000011001000100110001000001011100000,
      64'b0001110010101000011111011010100010001010111101001110110100101100,
      64'b0101001110111101011101001111100011011100001111001010001000001101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000001010011001100000001011010010100001100101000100110010111100,
      64'b0011110001000001111010101110110011111001110110001010011110111110,
      64'b0001011000011101001111000011001101001111100111111011010111011011,
      64'b1010001100110100101101100000000101110000001101100000001000011110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0010101000010001001111010001100010010111100100110010011010011100,
      64'b1100111010001100101101001000111111001100110101111010010000011011,
      64'b1010000011000001011010011001001010011011011111100100011011111001,
      64'b0000011000100101101100111100101100010101100001011111000111001101
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000111011110010100100001000100101000010011010101100010110000011,
      64'b1100010111100111001000111100110001101011011111011001001001111000,
      64'b0110110010010000000100000111100111001110101100001111010111011010,
      64'b0101111100101111000100101011010010100101100101111001101100101110
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100101110001100101011100011101001110110011111111011001001111001,
      64'b0100101010110100011100001101010001101110100100010011110111100001,
      64'b0110111111100000100011101101000011101110011010110010100110001011,
      64'b1011110001101011001111100011100101101101100111100100111001101111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101110000111100010101011100110110111000001010001111001000110101,
      64'b0111010100001010010101101001001101101010001101001001110010110110,
      64'b0101010011011100101011111110001011011010111001001001010101101101,
      64'b1001001101010101011100000000001100010100101001010111011001010111
    };
    text = $sformatf("%0d", source);
    parsed = '1;
    scanned = $sscanf(text, "%d", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101011110000001011101001011111101110111100011100111001001011101,
      64'b0010101111110011111011101100101101101001001011011101111001111000,
      64'b0111111010000010100100011100110100100100111111000100100101100011,
      64'b1111110011011010011010110101001001111110100010011010001101111111
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
