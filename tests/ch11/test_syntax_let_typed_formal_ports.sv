/*
:name: test_syntax_let_typed_formal_ports
:description: let ports with attribute instances, data types, untyped, an unpacked dimension and default expressions, where a typed formal casts its actual and a default is evaluated where the let is used (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12 A.2.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_let_typed_formal_ports.expected
*/
// IEEE 1800-2023 A.2.12: each let port is optional attribute instances, a
// data type, nothing or untyped, the formal name, optional unpacked
// dimensions and an optional = default expression. §11.12: the actual of a
// typed formal is cast to the type of the formal before it replaces the
// formal; an untyped formal takes the actual as it is; a formal with a
// default takes the default when its actual is omitted.
//
// lo_byte(logic [7:0] u) gives 300 cut to 8 bits, 44; sx(byte s) gives
// 8'hF0 as the signed byte -16. mid(int v [3]) takes a whole unpacked array
// of int, a type that can be cast to a 96-bit integral (6.24.3) and so is
// allowed for a let formal (16.6), and returns its middle element. plus has
// a formal p with no type, which takes its actual as it is, and a typed
// formal n whose default 9 and actual 20 are cast to 4 bits (20 gives 4).
// pick has an attribute on its first port, an untyped port y whose default
// is the variable b, and an int port z with the default 2; b is changed
// between two calls, so the omitted y takes the value b has at each call.
// Icarus Verilog 13.0 does not support these let declarations, and the
// other release reports let ports with types as unsupported.

module test_syntax_let_typed_formal_ports;
  int a = 5, b = 3;
  int arr [3] = '{10, 20, 30};

  let lo_byte(logic [7:0] u) = u;
  let sx(byte s) = s;
  let mid(int v [3]) = v[1];
  let plus(p, logic [3:0] n = 4'd9) = p + n;
  let pick((* role = "base" *) int x, untyped y = b, int z = 2) = x + y * z;

  initial begin
    $display("lo_byte=%0d sx=%0d mid=%0d", lo_byte(300), sx(8'hF0), mid(arr));
    $display("plus=%0d plus_n=%0d", plus(300), plus(1, 20));
    $display("pick=%0d skip_y=%0d", pick(a, 1, 4), pick(a, , 3));
    b = 4;
    $display("only_x=%0d named=%0d", pick(a), pick(.z(1), .x(7)));
  end
endmodule
