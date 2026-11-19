/*
:name: random_cross_case_0083
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0083;
  typedef bit signed [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b0111001111110000011000110011100011100101011101000110110110101010,
      64'b1101111110100101011001010000000000111100101000011111010010111110,
      64'b0101001001011110101100011011101001010101010011010010110011000101,
      63'b111101010011011110100010001001000010010111101000001101110100000
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
      64'b0110011101000011101100111111010101111001101111001110000010001101,
      64'b1100011010011100100010011011010010110010000011001101011111011101,
      64'b0110100011110001000100101001010110100110010010111010000001100100,
      63'b000110101101111110100010000111010100010010001111111110011111100
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
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      63'b111111111111111111111111111111111111111111111111111111111111111
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
      64'b1110011010010010111100110111111101011001011000001000001100100011,
      64'b0110010100010011001010001011110111001100010000000100101110000011,
      64'b1111001111111011110011000010110010111001011110101001011010001111,
      63'b011100110100110111010111000001110000011011101011111001110011010
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
      64'b1011011100010000011101011011000110001100001101101000000000010010,
      64'b1011000001011000010010100000110101100011011110111001101001101101,
      64'b1000000111000100110011000101101111101111111001101001011101110011,
      63'b001000001101100010101110011100110110011110000010100100010110100
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
      64'b0010000100001011010001011100001100010101101100101010010000001100,
      64'b1011011001111010110010101010110101100010111100100110001100000111,
      64'b0010111110001000010000101111000101111010000100010110101100100000,
      63'b110010100101100111100001100000011001010011111111100100010011001
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
      64'b1101001100000111000101000100001100011101101001011101000000111101,
      64'b1101101100011001101011000011110100001100101101101011011101010011,
      64'b0101101100100101000101010010111111010000111111110010101010000001,
      63'b101011010101110001001111010110011101100100100111010111011001111
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
      64'b0101001110000000111000010010000010000111000111101001100001010111,
      64'b0100101000010010010101111111001010001100001011100010111101100011,
      64'b1010100011100100001001000110101100110100101000010111100011000100,
      63'b100011100000101101011001000010101110101110001110100100110010111
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
