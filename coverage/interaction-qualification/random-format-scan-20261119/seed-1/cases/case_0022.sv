/*
:name: random_cross_case_0022
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 21.2.1.1 21.2.1.2 6.16.1 6.16.5 20.6.2
:oracle: spec
:spec_check: ai
:description: Bounded random comparison; replay the saved manifest.
*/
// Runtime-only case; not part of the registered fixed suite.
module random_cross_case_0022;
  typedef bit unsigned [254:0] word_t;
  word_t source, parsed;
  string text;
  integer scanned;
  initial begin
    source = {
      64'b1101001110101100000001111110010111000010000111000011010010001011,
      64'b0101101001101101101110111101110001001000101010101001100001001111,
      64'b0010100010010111110100100011010111010011101100101011110100101000,
      63'b001001100001000011001011110010000100111111000001011100110001010
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
      64'b1110001101111010110010100010011010111010111011010011100111010100,
      64'b1010101111000010000001111101000110001000111001100011100010001101,
      64'b1011001001001011001010010010110110011010000110111111011010010111,
      63'b101011101110010011011010000000001111011111011000001101111001110
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
      64'b0110011111011000000001110000001011100001001000101010101001001101,
      64'b1010101010010000000010100101011011000011011100101011010111111101,
      64'b1001011100011001011010010111111110110010101111100111101101000000,
      63'b010011111010101101100111001001000101000111001101000101011010011
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      63'b111111111111111111111111111111111111111111111111111111111111111
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
      64'b1111001111111111000110110100110100110101000101100001001001000001,
      64'b0100011100011010001111010101101110011001010010010110000001010111,
      64'b0101111110111000100011111000100101010101011100010011010000101100,
      63'b100101110011000010010001101100101000101000011101011011110101010
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
      64'b0111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      64'b1111111111111111111111111111111111111111111111111111111111111111,
      63'b111111111111111111111111111111111111111111111111111111111111111
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
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      64'b0000000000000000000000000000000000000000000000000000000000000000,
      63'b000000000000000000000000000000000000000000000000000000000000001
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
      64'b1100011101111010110110001100100000001111100011000010100010010000,
      64'b1110101101000111010111000011000000110011110010010000011100100111,
      64'b1100001111111111111100011010011111100010011101000001000100110011,
      63'b000111111011001100101001001110010111111001110101010010100001010
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
