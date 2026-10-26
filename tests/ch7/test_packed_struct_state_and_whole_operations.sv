/*
:name: test_packed_struct_state_and_whole_operations
:description: a packed structure is a two-state vector only when all members are two-state, converts two-state members on read and write, and takes part in whole operations as unsigned
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_packed_struct_state_and_whole_operations.expected
*/
// IEEE 1800-2023 7.2.1: a packed structure whose members are all two-state is
// treated as a two-state vector, while one four-state member makes the whole
// structure four-state. For a two-state member of a four-state packed
// structure, reads convert four-state to two-state and writes convert
// two-state to four-state. A packed structure can be used as a whole with
// arithmetic and logical operators, and it is unsigned by default. The test
// assigns x to both structures, writes and reads the two-state member, and
// compares the whole structure as an unsigned vector.

typedef struct packed {
  bit [3:0] a;
  bit b;
} two_t;

typedef struct packed {
  logic [3:0] a;
  bit b;
} four_t;

module test_packed_struct_state_and_whole_operations;
  two_t t;
  four_t f;
  two_t wrap;

  initial begin
    t = '1;
    $display("t_all=%b", t);
    t = 'x;
    $display("t_x=%b", t);
    f = 'x;
    $display("f_x=%b", f);
    f = 'x;
    f.b = 1'b1;
    $display("f_write=%b", f);
    f = 'x;
    $display("f_read_b=%b", f.b);
    t = 5'd31;
    wrap = t + 1;
    $display("wrap=%b", wrap);
    $display("signed_t=%0d", $signed(t));
    $display("cmp_lt=%0d cmp_ne=%0d", t < 0, t != 0);
  end
endmodule
