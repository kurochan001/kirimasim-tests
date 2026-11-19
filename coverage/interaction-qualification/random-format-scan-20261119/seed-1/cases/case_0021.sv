/*
:name: random_cross_case_0021
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0021;
  typedef bit unsigned [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      63'b111111111111111111111111111111111111111111111111111111111111111
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
      64'b1010010000100101001110001101101110010100111111000001111010010111,
      64'b1001101101101100100101010100101111011000101111110000000110111010,
      64'b1011010001101000110111000000100000111001011100111101110101000011,
      63'b111001011011100000110001100011011110101011111011101011010101011
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
      64'b1001001110011110111100010010001101011011101001100011110110011000,
      64'b0010111010100001000111110001100011001111011100011000010111110000,
      64'b1000101011001010111110010110100110111101101000110001100111001011,
      63'b110110101011111010000001101000010011011001011010101001101111101
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
      64'b0011100000101010000110111101001111001011111100001000010011000000,
      64'b1001101000101001001001101010100011001001100111000101000011101111,
      64'b1101111000100111110011010010101100010010010011110110010011111010,
      63'b110101100110001010011100000101110010000011111110010001101100000
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
      64'b0011110110010110101111111011000001011001101011001101010011100100,
      64'b0011100001000000101011100101001100000100010111011100110000011011,
      64'b0011001100111111001011101011100000011011100111011110011001010000,
      63'b010001000010100011010001110010110001100100100110101010001111010
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
      64'b0100010101011011111101001001011100010011111000011110100101000010,
      64'b1000000000110110000001001110111000001010001110111001111010100101,
      64'b0001011110000111101001110001010010001100100010100111011000101100,
      63'b110111101000010101111111111011011100101101100001111110010110010
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
      64'b0001000110101110111000101001011010111111001110000111011010110111,
      64'b0111110101100101100110010101001000110101000111110010111001111101,
      64'b0110101011110001010111110100000011001110011110111011001001110110,
      63'b010000001000110010101100000010001111001001001011101111001011111
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
      64'b1001010010110000110011011001100101011110100000100111101100111011,
      64'b0000001111000100000001000011011101110010010000100110110101110011,
      64'b1001101111100010010010000011001110110000000010001110110101001101,
      63'b000111000110100011001011110001010001011011101001110100111111000
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
