/*
:name: test_assignment_like_typed_parameters
:description: the value of a parameter with an explicit type, in a module, an interface, a program or a class, and its override in a module, interface or program instance, in a class specialization and before a class scope resolution operator, are assignment-like contexts, so assignment patterns and unpacked array concatenations there take the parameter's type (IEEE 1800-2023 Section 10.8)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.8 10.9 10.10
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_like_typed_parameters.expected
*/
// IEEE 1800-2023 §10.8: for a parameter declared with an explicit type, its
// value assignment in a module, interface, program or class, its override
// in the instantiation of a module, interface or program, and its override
// in a class specialization or on the left of the class scope resolution
// operator are assignment-like contexts. An assignment pattern without a
// type there takes the parameter's type (§10.9), and braces for a parameter
// of an unpacked array type are an unpacked array concatenation (§10.10).
// pair_t is a packed structure of two 8-bit members. A pattern of two ints
// gives one int to each member; as a vector concatenation it would be 64
// bits cut to 16, with hi = 0.
//   - tp_mod has a pair_t parameter P, an unpacked array parameter A of two
//     bytes and a pair_t localparam L with P's members swapped. u_def keeps
//     the values of the declarations, u_named overrides P and A by name and
//     u_pos by position.
//   - tp_if and tp_prog have a pair_t parameter P; one instance of each
//     keeps the declared value and one overrides it.
//   - tp_cls has a pair_t parameter P, and code() returns hi * 100 + lo.
//     It is called for the default specialization, through the class scope
//     resolution operator with an override, and on an object of a
//     specialization overridden by name.
// Each instance prints at its own time T. The programs print last, and the
// simulation ends when both of their initial procedures have ended (§24.3).
// Icarus Verilog 13.0 does not follow the clauses here, as it does not
// support unpacked array parameters; the 5.054 release of the Verilator
// tool matches the expected output. (The 5.052 release rejected a pattern
// without a type as a class parameter override ("Unsupported") and braces
// as the override of the unpacked array parameter ("Illegal assignment of
// constant to unpacked array").)

typedef struct packed {
  logic [7:0] hi;
  logic [7:0] lo;
} pair_t;

module tp_mod #(parameter pair_t P = '{1, 2}, parameter logic [7:0] A [2] = {8'd3, 8'd4},
                parameter int T = 0) ();
  localparam pair_t L = '{P.lo, P.hi};
  initial #T $display("%m: P=%0d,%0d A=%0d,%0d L=%0d,%0d", P.hi, P.lo, A[0], A[1], L.hi, L.lo);
endmodule

interface tp_if #(parameter pair_t P = '{5, 6}, parameter int T = 0) ();
  initial #T $display("%m: P=%0d,%0d", P.hi, P.lo);
endinterface

program tp_prog #(parameter pair_t P = '{7, 8}, parameter int T = 0) ();
  initial #T $display("%m: P=%0d,%0d", P.hi, P.lo);
endprogram

class tp_cls #(parameter pair_t P = '{9, 10});
  static function int code();
    return P.hi * 100 + P.lo;
  endfunction
endclass

module test_assignment_like_typed_parameters;
  tp_cls #(.P('{31, 32})) h;

  tp_mod #(.T(1)) u_def();
  tp_mod #(.P('{11, 12}), .A({8'd13, 8'd14}), .T(2)) u_named();
  tp_mod #('{15, 16}, {8'd17, 8'd18}, 3) u_pos();
  tp_if #(.T(4)) i_def();
  tp_if #(.P('{25, 26}), .T(5)) i_ovr();
  tp_prog #(.T(7)) p_def();
  tp_prog #('{27, 28}, 8) p_ovr();

  initial begin
    h = new;
    #6 $display("class: default %0d, scope resolution %0d, object %0d", tp_cls#()::code(),
                tp_cls#('{21, 22})::code(), h.code());
  end
endmodule
