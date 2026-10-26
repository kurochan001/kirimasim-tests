/*
:name: test_typename_enum_encoded_values
:description: the string that $typename returns for an enumeration includes the encoded value of each named constant, so two enumerations that differ only in those values have different strings (IEEE 1800-2023 Section 20.6.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typename_enum_encoded_values.expected
*/
// IEEE 1800-2023 §20.6.1: when $typename builds the name of an enumeration it
// appends the actual encoded value of every named constant. The test declares
// in three packages the same enumeration names RED and GREEN; in the first and
// the third packages the encoded values are 0 and 3, and in the second they
// are 0 and 4. The part of the returned string between the braces is taken
// out, which leaves the constants and their values without the package name
// that step f adds. The parts of the first and the third package are equal, so
// the extraction keeps the constants; the parts of the first and the second
// differ, so the values are part of the string. A tool that names the
// constants without their values would make the second comparison equal, and
// one that returns the whole string without braces would make the first
// comparison differ.

package first_pkg;
  typedef enum { RED = 0, GREEN = 3 } color_t;
endpackage

package second_pkg;
  typedef enum { RED = 0, GREEN = 4 } color_t;
endpackage

package third_pkg;
  typedef enum { RED = 0, GREEN = 3 } color_t;
endpackage

module test_typename_enum_encoded_values;
  function automatic string constants_only(string name);
    int open = -1, close = -1;
    for (int i = 0; i < name.len(); i++) begin
      if (name.getc(i) == "{" && open < 0) open = i;
      if (name.getc(i) == "}") close = i;
    end
    if (open < 0 || close <= open) return name;
    return name.substr(open, close);
  endfunction

  initial begin
    string a = constants_only($typename(first_pkg::color_t));
    string b = constants_only($typename(second_pkg::color_t));
    string c = constants_only($typename(third_pkg::color_t));
    $display("first and third: %0d", a == c);
    $display("first and second: %0d", a == b);
    $display("same type: %0d", a == constants_only($typename(first_pkg::color_t)));
  end
endmodule
