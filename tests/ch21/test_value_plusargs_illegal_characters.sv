/*
:name: test_value_plusargs_illegal_characters
:description: When the rest of a matching plusarg holds a character that the conversion of $value$plusargs does not allow, the variable is written with 'bx, all bits unknown (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:args: +bad_d=12a +bad_h=fg +bad_b=102 +bad_o=79 +good_h=fe
:expected_stdout: @test_value_plusargs_illegal_characters.expected
*/
// IEEE 1800-2023 §21.6: if the string available for conversion holds
// characters that are illegal for the conversion, the variable is written with
// the value 'bx. a is not a decimal digit, g not a hexadecimal one, 2 not a
// binary one and 9 not an octal one; the variables, set to 0 first, then hold
// x in every bit. A legal remainder, fe for %h, is converted as usual. The run
// gets the plusargs of :args:. Icarus Verilog 13.0 stores 'bx but also prints
// a warning for each call on the standard output, so its output is not the
// expected one; the 5.052 release of Verilator converts the digits before the
// illegal character (12 for 12a).

module test_value_plusargs_illegal_characters;
  logic [7:0] v;

  task automatic try(string key);
    v = 8'h00;
    void'($value$plusargs(key, v));
    $display("%s: %b", key, v);
  endtask

  initial begin
    try("bad_d=%d");
    try("bad_h=%h");
    try("bad_b=%b");
    try("bad_o=%o");
    try("good_h=%h");
  end
endmodule
