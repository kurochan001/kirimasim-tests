/*
:name: test_illegal_sort_with_struct_expression
:description: sort() needs the relational operators on the element type when it has no with clause, and on the type of its with expression when it has one; a with expression of unpacked structure type is an error (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the with expression of sort() on the array r is the unpacked structure item
:expected_stderr_regex: test_illegal_sort_with_struct_expression\.sv:37:
*/
// IEEE 1800-2023 §7.12.2: sort() sorts the array in ascending order. Its with
// clause may be omitted when the relational operators <, > and == are defined
// for the element type, and when a with clause is given, those operators shall
// be defined for the type of its expression.
// The array r has elements of the unpacked structure type rec_t. The legal call
// sorts r with the int expression item.key, and the legal design prints the
// keys: 1 2 3. The last call has the with expression item, an unpacked
// structure.
// The relational operators of 11.4.4 compare integral or real operands, and
// none of them is defined for an unpacked structure.
// Icarus Verilog 13.0 does not support unpacked structures or the with clause
// of array methods and reports errors on them, which do not count. The 5.052
// release accepts the design.

module test_illegal_sort_with_struct_expression;
  typedef struct { int key; int val; } rec_t;
  rec_t r [3];
  initial begin
    r[0].key = 3;
    r[1].key = 1;
    r[2].key = 2;
    r.sort with (item.key);
    $display("%0d %0d %0d", r[0].key, r[1].key, r[2].key);
    r.sort with (item);   // illegal: the with expression is an unpacked structure
  end
endmodule
