/*
:name: test_array_whole_slice_equality_operations
:description: fixed unpacked, packed, dynamic, queue and associative arrays are read and written whole and compared with == and !=, constant-width slices with variable positions are copied and compared, and a slice of a packed array is packed while a slice of an unpacked array is unpacked (IEEE 1800-2023 Sections 7.4.6, 7.4.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.6 7.4.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_whole_slice_equality_operations.expected
*/
// IEEE 1800-2023 §7.4.6: all arrays, packed or unpacked, can be read and
// written as a whole, element by element and by slices of a constant width,
// and compared with == and !=, whole or by slices;
// associative arrays can be read, written and compared as a whole but not
// sliced. §7.4.5: the width of a slice is constant while its position can
// vary, a slice of a packed array is a packed array, and a slice of an
// unpacked array is an unpacked array.
// Each comparison is printed before and after one element is changed, so it
// has to give both 1 and 0. The slices of the packed array have variable
// positions i and j. The packed slice P[2:1] is added to as a 16-bit
// vector; the unpacked slice B[4:5] is assigned to, and compared with, an
// unpacked array of two elements.
// Icarus Verilog 13.0 does not support the associative arrays of this test.

module test_array_whole_slice_equality_operations;
  int A [0:5], B [0:5];
  int two [0:1];
  logic [5:0][7:0] P, Q;
  int d1[], d2[];
  int q1[$], q2[$];
  int aa[string];
  int ab[string];
  int i, j;

  initial begin
    foreach (B[k]) B[k] = 10 * k;
    A = B;
    $display("fixed whole: A[0]=%0d A[5]=%0d A==B=%0d A!=B=%0d", A[0], A[5], A == B, A != B);
    A[3] = -1;
    $display("after A[3]=-1: A==B=%0d A!=B=%0d", A == B, A != B);
    A[1 +: 2] = B[3 +: 2];
    $display("fixed slice copy: A[1]=%0d A[2]=%0d A[3]=%0d", A[1], A[2], A[3]);
    $display("fixed slice compare: A[1+:2]==B[3+:2]=%0d A[1+:2]!=B[3+:2]=%0d A[1+:2]==B[0+:2]=%0d",
             A[1 +: 2] == B[3 +: 2], A[1 +: 2] != B[3 +: 2], A[1 +: 2] == B[0 +: 2]);
    two = B[4:5];
    $display("unpacked slice: two=%0d,%0d two==B[4:5]=%0d two==B[3:4]=%0d", two[0], two[1],
             two == B[4:5], two == B[3:4]);

    P = 48'h05_04_03_02_01_00;
    Q = P;
    $display("packed whole: P==Q=%0d", P == Q);
    i = 4;
    j = 0;
    Q[i -: 2] = P[j +: 2];
    $display("packed slice copy: Q=%h P==Q=%0d P!=Q=%0d Q[i-:2]==P[j+:2]=%0d", Q, P == Q, P != Q,
             Q[i -: 2] == P[j +: 2]);
    $display("packed slice as vector: bits=%0d P[2:1]+1=%h", $bits(P[2:1]), P[2:1] + 16'h1);

    d1 = B;
    d2 = d1;
    q1 = '{10, 20, 30};
    q2 = q1;
    $display("dynamic: size=%0d d1==d2=%0d; queue: size=%0d q1==q2=%0d", d2.size(), d1 == d2,
             q2.size(), q1 == q2);
    d2[5] = 0;
    q2[2] = 0;
    $display("after changes: d1==d2=%0d d1!=d2=%0d q1==q2=%0d q1[0:1]==q2[0:1]=%0d",
             d1 == d2, d1 != d2, q1 == q2, q1[0:1] == q2[0:1]);

    aa["x"] = 1;
    aa["y"] = 2;
    ab = aa;
    $display("associative: num=%0d ab[\"y\"]=%0d aa==ab=%0d", ab.num(), ab["y"], aa == ab);
    ab["y"] = 3;
    $display("after ab[\"y\"]=3: aa==ab=%0d aa!=ab=%0d aa[\"y\"]=%0d", aa == ab, aa != ab,
             aa["y"]);
  end
endmodule
