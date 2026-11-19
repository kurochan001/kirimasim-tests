/*
:name: random_cross_case_0060
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0060;
  typedef bit unsigned [256:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0100000101110010001001101100110001100000010010010110001000111101,
      64'b0001110000101010100101111100100000010111101100101010110011011110,
      64'b0011001010010001100010010101000010011101101000000010111100110100,
      64'b1011111000011011110000010000101101100011001000010100100010101111,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0110001111010001000001101110100001111100101001100011101011101000,
      64'b1101011111010110000000000011111000000100111011001100000000010001,
      64'b1011010111010000110110111101001111011000100010110011110010100000,
      64'b0011001000110101010001010011100010101111101100001100011011110110,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0111101000101011110001011101011111010101010001111100001001001000,
      64'b0101001111000100010000100010010111100100011000100011011001111110,
      64'b1010010000011011011101011010111101011110110010101000001011101001,
      64'b0010001100111000011010011001001100110100110010101111100001000000,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011101110111001110110100001001001111010011111100011010110111110,
      64'b1111110110011110111011010010110001010001000110001100001111011001,
      64'b1111001101110000101000110011011011011101011011100011110111111111,
      64'b0110101110010100011001011011111010011100001110110011000001000110,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      1'b0
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0000100110010101101011111110011001100100101010111001001110100000,
      64'b0000011000000110011000010000011011110001100001010011011110011100,
      64'b0101100100001010110111100001100001010101111101100011000110010001,
      64'b1011101011111011010010101000100111001111010101011010110111100111,
      1'b1
    };
    text = $sformatf("%0b", source);
    parsed = '1;
    scanned = $sscanf(text, "%b", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b0001101001001110111000100110010011101111000101110000101001111010,
      64'b1110110110011001010000101100000000000101010011100011010111011000,
      64'b0110110000001011100101001101111110001011100101101010100010011100,
      64'b1011001110110110111110010110001001101100001010011001101011011100,
      1'b1
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
