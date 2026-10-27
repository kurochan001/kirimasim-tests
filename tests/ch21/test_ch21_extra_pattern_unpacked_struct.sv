/*
:name: test_ch21_extra_pattern_unpacked_struct
:description: %p prints an unpacked structure as an assignment pattern whose elements carry their names, with string members printed as quoted strings (IEEE 1800-2023 Section 21.2.1.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch21_extra_pattern_unpacked_struct.expected
*/
// IEEE 1800-2023 §21.2.1.6: for unpacked structure data types, %p "shall
// print the value as an assignment pattern with named elements"; a string
// data type or string literal prints "as a string enclosed in quotes", and
// the use of white space is implementation dependent as long as the result
// is a legal assignment pattern. The test removes white space from the
// formatted text and prints it, so only the names, the quotes and the
// element values are compared. The structure has two string members, the
// only member type for which both the name and the value form are fixed by
// the clause without a radix choice.
//
// Icarus Verilog 13.0 does not support unpacked structures. Verilator 5.052
// prints this structure as shown. The union half of the clause (only the
// first declared element, and tag:value for a tagged union) is not covered
// here: Verilator 5.052 prints every member of an unpacked union and does
// not support tagged unions, and Icarus Verilog has neither.

module test_ch21_extra_pattern_unpacked_struct;
  typedef struct {
    string name;
    string value;
  } record_t;

  record_t record = '{name: "alpha", value: "beta"};

  function automatic string compact(string text);
    string out = "";
    for (int i = 0; i < text.len(); i++) begin
      if (text[i] == " " || text[i] == "\t" || text[i] == "\n") continue;
      out = {out, text[i]};
    end
    return out;
  endfunction

  initial begin
    $display("record=%s", compact($sformatf("%p", record)));
  end
endmodule
