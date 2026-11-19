/*
:name: random_cross_case_0013
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0013;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1000010101011101001011011101101101000011101001011110111001110111,
      64'b0001010111110000010110000100101011101000010011011010010111110001,
      64'b1111011110011101001001100011101001001000011110001010011010101110,
      64'b1000000111001000100001100100011001000100101000111111100100101010
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
      64'b0001111110100010001010101000011101110011000000011111100011001011,
      64'b1100011001101111111010101100011100110011011000111001000111010010,
      64'b1001101111100110000010101011011001010100100101001011101011110101,
      64'b0110100000101100011111011001110111011111111111010001000001101111
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
      64'b1011000001010100100100011010110111100110110010000101110100100111,
      64'b1000000100010110001110110101001010110101001101100111110000100110,
      64'b1100010010001110101110010110111010111101000101101111110001101111,
      64'b0010101100110001011001100001111011001111100011010111010110000011
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
      64'b0101101101111001111011111100110100011101011111000011101001111000,
      64'b0101101000100101010110001110011100000000110101001011110110111111,
      64'b1001010001011010100111010011011010000110111000111101100100100001,
      64'b0000110111100001011001000100001100001010001010000001000000100001
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
      64'b0010101010010110010100001100110100111010110100101111100110110001,
      64'b1000100011010111010001011010110111010000010010111011100100100101,
      64'b0101011100001101110111001101111010011100000010111010010001011001,
      64'b1000110010110101110000100111100101111100100001010000100110001101
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000001
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
      64'b1001001111111110011110000010110000101111001010011010110111010110,
      64'b0010111101110011110100101101000101001011110001011011010100000110,
      64'b1011000010110010011100011101000101011111010011101101000110000001,
      64'b0000111001011001111001101110111110110001111110110110101111101100
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
      64'b0100001101100111001110011110100001110100111011111001010111110000,
      64'b1110110010001101101110011111101101010001000011101111111010100010,
      64'b1000000011101111110010101110100100110011100100110011100010010011,
      64'b0001010011001010001101011101001100100110010000010101101010101110
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
