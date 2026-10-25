/*
:name: test_declaration_range_forms
:description: Packed dimensions as a constant range, unpacked dimensions as a constant range and as a constant expression with more than one dimension, associative dimensions with a data type and with the asterisk index, a queue dimension with and without a bound, an unsized dimension for a dynamic array, and a variable dimension built from these (IEEE 1800-2023 Sections 7.4, 7.5, 7.8 and 7.10)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 7.5 7.8 7.10 A.2.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_declaration_range_forms.expected
*/
// IEEE 1800-2023 A.2.5: an unpacked dimension is a bracketed constant range
// or a bracketed constant expression; a packed dimension is a bracketed
// constant range or an unsized dimension; an associative dimension is a
// bracketed data type or a bracketed asterisk; a queue dimension is a
// bracketed $ with an optional colon and constant expression; an unsized
// dimension is empty brackets; a variable dimension is any of those.
//   - p1 has a packed range, p2 two packed ranges of 8 bits, p3 a packed
//     range and an unpacked dimension,
//   - u1 has an unpacked range, u2 an unpacked size and u3 two unpacked
//     dimensions,
//   - a1 is indexed by string, a2 by the asterisk index and a3 by int,
//   - q1 is a queue without a bound, q2 a queue bounded by 3 and d1 a dynamic
//     array whose unsized dimension is given its size with new[2].
// Each variable is written at the two ends of its index range or through the
// method of its kind, and the sum of two elements shows the value each form
// carries: p3 = 3, u1 = 5, u2 = 13, u3 = 15, a1 = 10, a2 = 11, a3 = 12,
// q1 = 13/14, q2 = 15/16/17 with size 3 and d1 = 18/19 with size 2.
//
// Icarus Verilog 13.0 does not accept the asterisk index.

module test_declaration_range_forms;
  logic [7:0] p1;
  logic [3:0][1:0] p2;
  bit [3:0] p3 [2];
  int u1 [0:3];
  int u2 [4];
  int u3 [1:0][2];
  int a1 [string];
  int a2 [*];
  int a3 [int];
  int q1 [$];
  int q2 [$:3];
  int d1 [];

  initial begin
    p1 = 8'h5A;
    p2 = 6'b110011;
    p3[0] = 4'h1;
    p3[1] = 4'h2;
    u1[0] = 1;
    u1[3] = 4;
    u2[0] = 5;
    u2[3] = 8;
    u3[0][0] = 6;
    u3[1][1] = 9;
    a1["k"] = 10;
    a2[2] = 11;
    a3[7] = 12;
    q1.push_back(13);
    q1.push_back(14);
    q2.push_back(15);
    q2.push_back(16);
    q2.push_back(17);
    d1 = new[2];
    d1[0] = 18;
    d1[1] = 19;
    #1 $display("packed: p1=%h p2=%b p3=%h", p1, p2, p3[0] + p3[1]);
    $display("unpacked: u1=%0d u2=%0d u3=%0d",
             u1[0] + u1[3], u2[0] + u2[3], u3[0][0] + u3[1][1]);
    $display("assoc: a1=%0d a2=%0d a3=%0d", a1["k"], a2[2], a3[7]);
    $display("queue: q1=%0d/%0d q2=%0d/%0d/%0d size=%0d",
             q1[0], q1[1], q2[0], q2[1], q2[2], q2.size());
    $display("unsized: d1=%0d/%0d size=%0d", d1[0], d1[1], d1.size());
  end
endmodule
