/*
:name: random_cross_case_0094
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0094;
  typedef bit unsigned [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1111000011010110110110011010100110010001100101010110110010000110,
      64'b0000011101000101011111010011010111010100110000011101010101101101,
      64'b0110001111111111110001010000110111100011010000011000011011001101,
      63'b011010000100001000001101110111001000011011111111100101111100011
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v0_input=%b", source);
    $display("v0_text=%s length=%0d", text, text.len());
    $display("v0_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100110111101110000001010001101011101110011101010101001111001111,
      64'b0110100001000111010000111001101010110011110011100011011000011111,
      64'b1011011100000011000101001111010001111001000010110110001100111001,
      63'b110110011111000010010011110001101101100011110100000011011100101
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v1_input=%b", source);
    $display("v1_text=%s length=%0d", text, text.len());
    $display("v1_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1100001001010011011010111001010101101111101011000110001100101101,
      64'b1001110011101100010111111101010001001010000111110100100000101100,
      64'b0000010111101100110011001000001110000001010101001111000111110111,
      63'b000010100000010100010100101111001110000110100010000111100000011
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v2_input=%b", source);
    $display("v2_text=%s length=%0d", text, text.len());
    $display("v2_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1101100001100110101100011011011001110010101011010000100010101000,
      64'b1011101011111101010000001110010010001011100110000100101100011010,
      64'b0111001101011011010010101001111000110010101011010111111000101111,
      63'b011000100001111000011101111110111001001011010010101101111001101
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v3_input=%b", source);
    $display("v3_text=%s length=%0d", text, text.len());
    $display("v3_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1011001111101001000001111011001000010011111100011000100000001111,
      64'b0110010111000100011000100100000110101011011001000001100110010110,
      64'b1011110001001111011011011101010010110111001100110011100111001110,
      63'b111000111011111010011000011101011110110011011101110110011101001
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v4_input=%b", source);
    $display("v4_text=%s length=%0d", text, text.len());
    $display("v4_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000110101011101000111110011000110110000011011000110000001001011,
      64'b1010000100100001010110100101010101010010110011101100011001111010,
      64'b1011000111111100000100010111101010110100111001110101011110100011,
      63'b000100000100100101110111000101101100011100000111010001001111110
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v5_input=%b", source);
    $display("v5_text=%s length=%0d", text, text.len());
    $display("v5_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1000111010010000000000010000010000110101000000111111011111110100,
      64'b0001101101000110011011010000101000101010000011010001100000100110,
      64'b1110101010100011100000101111100010000101010000010011101000011111,
      63'b000001001010100100011001001111001001101010111111110000110101010
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v6_input=%b", source);
    $display("v6_text=%s length=%0d", text, text.len());
    $display("v6_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    source = {
      64'b1001010111011110000111101101010100011101010010101001100110111010,
      64'b1101101010100011001000000110101001101100110010011001101011010101,
      64'b1001111100011100110001101011101111010110110110000110101110010010,
      63'b100111101000100110110001100110010111110000110011001000000011001
    };
    text = $sformatf("%0h", source);
    text = text.tolower();
    parsed = '1;
    scanned = $sscanf(text, "%h", parsed);
    $display("v7_input=%b", source);
    $display("v7_text=%s length=%0d", text, text.len());
    $display("v7_parsed=%b count=%0d source_after=%b",
             parsed, scanned, source);
    $display("widths=%0d,%0d", $bits(source), $bits(parsed));
    $finish;
  end
endmodule
