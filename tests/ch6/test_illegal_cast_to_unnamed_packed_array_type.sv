/*
:name: test_illegal_cast_to_unnamed_packed_array_type
:description: the cast operator takes only a simple type name, so a type with a packed dimension needs a user-defined type name to be the target of a cast (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cast logic [3:0]'(v) writes a type with a packed dimension as the casting type instead of a type name
:expected_stderr_regex: test_illegal_cast_to_unnamed_packed_array_type\.sv:27:
*/
// IEEE 1800-2023 §6.18: user-defined type names are needed for complex data
// types in casting, which allows only simple data type names (6.24.1: the
// casting type is a simple type, a constant expression for a size cast, a
// signing, string or const).
// The casts nib_t'(v), with the typedef nib_t of logic [3:0], logic'(v) and the
// size cast 4'(v) are legal, and the legal design prints them: 9 1 9. The last
// cast writes logic [3:0] itself before the apostrophe.

module test_illegal_cast_to_unnamed_packed_array_type;
  typedef logic [3:0] nib_t;
  logic [7:0] v = 8'h29;
  initial begin
    $display("%h %h %h", nib_t'(v), logic'(v), 4'(v));
    $display("%h", logic [3:0]'(v));   // illegal: packed dimension in the casting type
  end
endmodule
