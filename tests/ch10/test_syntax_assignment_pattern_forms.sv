/*
:name: test_syntax_assignment_pattern_forms
:description: Assignment patterns with positional expressions, structure and array keys, default and replication, the type prefixes of A.6.7.1, and assignment pattern lvalues for variables and nets, set every member they name (IEEE 1800-2023 Sections 10.9.1 and 10.9.2, A.6.7.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9 10.9.1 10.9.2 A.6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_assignment_pattern_forms.expected
*/
// IEEE 1800-2023 A.6.7.1: an assignment pattern is "'{ expression {,
// expression } }", a brace list of structure or array keys and
// expressions, or a constant replication count before a brace list. Its
// expression form may have a package-scoped type identifier, a
// package-scoped parameter identifier, an integer atom type or a type
// reference before the brace. A net or variable lvalue may also be a brace
// list of the corresponding lvalues. §10.9.1 and §10.9.2: each member is
// assigned to its element or field, an index key sets that element, default
// sets the rest, and a replication repeats its members.
//
// pos, named, dflt, typed and param_typed are patterns for the packed
// structure pair_t written with positional expressions, member keys, default,
// the type name pair_t, and the type parameter PT. ia is the integer atom
// type int with a replication that covers its 32 bits with ones, and tr is
// the same with the type reference type(1). arr uses the array keys 0 and 3
// and default, and rep repeats 7 three times. The variable lvalue pattern
// assigns 3 and 4, the net lvalue pattern in a continuous assignment drives
// 1 and 2, and each print shows the resulting values.
//
// The expected output follows the standard; neither the Icarus Verilog 13.0
// release nor the Verilator 5.052 release supports assignment pattern
// lvalues, and Icarus Verilog 13.0 does not support the other forms beyond a
// positional pattern.

module test_syntax_assignment_pattern_forms;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } pair_t;

  parameter type PT = pair_t;

  pair_t pos = '{4'h1, 4'h2};
  pair_t named = '{hi: 4'h3, lo: 4'h4};
  pair_t dflt = '{default: 4'h5};
  pair_t typed = pair_t'{hi: 4'h6, lo: 4'h7};
  pair_t param_typed = PT'{hi: 4'h8, lo: 4'h9};
  int ia = int'{32{1'b1}};
  int arr[4] = '{0: 1, 3: 2, default: 0};
  int rep[3] = '{3{7}};

  logic [3:0] a, b;
  wire [3:0] n0, n1;

  assign '{n0, n1} = '{4'h1, 4'h2};

  initial begin
    int tr = type(1)'{32{1'b1}};
    logic [3:0] va, vb;

    '{va, vb} = '{4'h3, 4'h4};

    $display("pos=%h named=%h dflt=%h", pos, named, dflt);
    $display("typed=%h param_typed=%h ia=%h", typed, param_typed, ia);
    $display("arr=%0d %0d %0d %0d", arr[0], arr[1], arr[2], arr[3]);
    $display("rep=%0d %0d %0d", rep[0], rep[1], rep[2]);
    $display("variable lvalue=%h %h", va, vb);
    $display("net lvalue=%h %h", n0, n1);
    $display("type reference=%h", tr);
  end
endmodule
