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
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1001111101111001100101110010010111000111101111111110000010110111,
      64'b0001100111110101011001001101101011110111100101101011000100111001,
      64'b0111110000001001010001000010110110011110011101110101110101110000,
      63'b100010100001000010000110101101110010100110110000101010100110001
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
      64'b1000100010110101011011111000000001100011100011111011001101001010,
      64'b1100101001110100000010001011100010101011001101110101000000011000,
      64'b1010000001111110101101000001000011000100110010101010101000111101,
      63'b001111010110111101010000010100010101001011111000111110100001011
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
      64'b1011110010101010100010000100011001100100100110101100010011111110,
      64'b0011110110110110011000001001100011100001101011101101101110000001,
      64'b0000110000010110101010100111010111010110001101000010010010110010,
      63'b111011010101101111101100010101110101100111110011011010010000110
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
      64'b0111111010111011011110011110101001011001001110100011010101001010,
      64'b1101111101101001011000110110010101010010100010010100110010100001,
      64'b1010101111011001011001001110010101101011100100000001101101110110,
      63'b001010101001100011010001101010110010000111100010111000010100000
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
      64'b0000101100000110101110010100110001111011011100100001100000000001,
      64'b1110001111101100111101111000011101110010001110110100010001101111,
      64'b0101111000000010001010100100010111100111011100111100100101000101,
      63'b110010101010010110100110100000111111101100000001001100110111110
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
      64'b0000011111100111100001110011101111111111110011011110000001110000,
      64'b1110011100110111100011111010000100010001001001110010100010101111,
      64'b0110111100011111011111100001001101110101010001101101010100110011,
      63'b001100110011010010101110010101101010010001010011101111111111111
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
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      63'b111111111111111111111111111111111111111111111111111111111111111
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
      64'b1010111000100101011010101011110101110110001111101000110100110101,
      64'b0000100010001001000100010110101110010001100100001100010100011101,
      64'b1111000010011000101100101101000110111011001111000010111110110011,
      63'b001011011010010111101110001111000001000111100011010100010001010
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
