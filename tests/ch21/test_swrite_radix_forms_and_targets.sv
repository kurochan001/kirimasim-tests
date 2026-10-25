/*
:name: test_swrite_radix_forms_and_targets
:description: $swrite, $swriteb, $swriteh and $swriteo format like $fwrite and its forms, with their default radix and no newline, and store the text into a string, or into an integral variable right-justified with zeros on the left or with the leftmost characters cut off (IEEE 1800-2023 Section 21.3.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 5.9 21.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_swrite_radix_forms_and_targets.expected
*/
// IEEE 1800-2023 §21.3.3: the $swrite tasks take the arguments of the $fwrite
// tasks (21.3.2), except that the first one is a variable of an integral type,
// an unpacked array of bytes or the string type that receives the text. The
// variable is assigned by the rules for assigning a string literal (5.9): an
// integral variable gets the text right-justified, padded with zeros on the
// left or with its leftmost characters cut off. With v = 8'd10, $swrite gives
// " 10", $swriteb 00001010, $swriteh 0a and $swriteo 012, without a newline; a
// string literal argument holds format specifications as in $fwrite. The test
// of an unpacked array of bytes as target is
// test_swrite_unpacked_byte_array_order.

module test_swrite_radix_forms_and_targets;
  logic [7:0] v;
  string s;
  logic [8*4-1:0] i4;
  logic [8*6-1:0] i6;
  logic [8*2-1:0] i2;

  initial begin
    v = 8'd10;
    $swrite(s, v);
    $display("swrite: [%s] len=%0d", s, s.len());
    $swriteb(s, v);
    $display("swriteb: [%s]", s);
    $swriteh(s, v);
    $display("swriteh: [%s]", s);
    $swriteo(s, v);
    $display("swriteo: [%s]", s);
    $swrite(s, "a=", v, " b=%0d", 8'd5);
    $display("swrite mixed: [%s]", s);

    $swriteh(i4, 16'hbeef);
    $display("integral exact: %s", i4);
    $swrite(i6, "ab");
    $display("integral wider: %h", i6);
    $swrite(i2, "%s", "WXYZ");
    $display("integral narrower: %s", i2);

  end
endmodule
