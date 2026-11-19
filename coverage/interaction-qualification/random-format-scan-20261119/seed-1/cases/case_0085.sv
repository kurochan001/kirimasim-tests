/*
:name: random_cross_case_0085
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0085;
  typedef bit unsigned [255:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1111001010110100100000111101110110011101010100000100000100011000,
      64'b0011010100011100001100001110100111100011001110000000100110001100,
      64'b1010101100010100011101101100100010110011000000001101101011100011,
      64'b1100010011111011101001011111010010100101110001000001100010101111
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
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
      64'b0101110101111100100101111110110001111000010000000000010111100001,
      64'b0111011000000001000000000011100001110110101001001000111100000100,
      64'b1010110101011011100010101011010110101011110100001011111000011111,
      64'b0100011010011111011000111100101111001011000011010011100011100010
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
      64'b0000111000110111111100010110100111110000110101000010010011000010,
      64'b0101100000110001111000110010111000111001100111111011110100110000,
      64'b1111000100111010100101001110111011111001000100000111000000001110,
      64'b0001000101111001011100111101111001101100010001001100101000000100
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
      64'b1111111011110000011101111011100001111111111101111101001110001001,
      64'b1011000110010001011001101101111010110111000000000111000010011000,
      64'b1000101110001101110011101110010101100010001100000100011101111110,
      64'b1010101100101010010001010101111000011010100111011101001110001101
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
      64'b1110001001000100101110000011000001111111001100000101011001000100,
      64'b0100010010101111111011110000000111001100100010001000000011001100,
      64'b0001000110000111101011100011101000110011111111001100011010101110,
      64'b1110011111110100000001011100101000100100011111101111000100101110
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
      64'b0100011110110111010111011001001110011000110100010011000000001011,
      64'b0111111000010000011000001100011000010100100000011001011100111011,
      64'b1000101100101000011101001100100001110111001010011100110111110110,
      64'b0101000110010000010000100010101101110111111101001111000100101000
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111
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
