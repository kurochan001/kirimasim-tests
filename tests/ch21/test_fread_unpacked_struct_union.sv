/*
:name: test_fread_unpacked_struct_union
:description: $fread into an unpacked structure fills its members in declaration order, each from its own bytes, and into an unpacked union fills only its first member (IEEE 1800-2023 Section 21.3.4.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fread_unpacked_struct_union.expected
*/
// IEEE 1800-2023 §21.3.4.4: for unpacked struct data, $fread works as if it
// read each member in declaration order; for unpacked union data, as if it
// read the first member. The structure has members of 8, 16 and 32 bits, so it
// takes 7 bytes, 1 into a, the next 2 into b and the next 4 into c, each big
// endian. The union has a 16-bit first member and a 32-bit second member, so
// it takes 2 bytes, into the first member. The file holds the bytes 01 to 0c
// (hex); $fgetc shows the byte after the union, printed with %h as the
// 32-bit int c, so with eight digits. The result is the number of
// bytes read. The file is created in the current directory. Icarus Verilog
// 13.0 does not support unpacked structures, and the 5.052 release
// of Verilator rejects $fread into a variable that is not an unpacked array.

module test_fread_unpacked_struct_union;
  typedef struct {
    logic [7:0] a;
    logic [15:0] b;
    logic [31:0] c;
  } rec_t;
  typedef union {
    logic [15:0] h;
    logic [31:0] w;
  } alt_t;

  int fd, n, c;
  rec_t r;
  alt_t u;

  initial begin
    fd = $fopen("test_fread_unpacked_struct_union.bin", "wb");
    for (int i = 1; i <= 12; i++) $fwrite(fd, "%c", i[7:0]);
    $fclose(fd);

    fd = $fopen("test_fread_unpacked_struct_union.bin", "rb");
    n = $fread(r, fd);
    $display("struct: n=%0d a=%h b=%h c=%h", n, r.a, r.b, r.c);
    n = $fread(u, fd);
    c = $fgetc(fd);
    $display("union: n=%0d h=%h next=%h", n, u.h, c);
    $fclose(fd);
  end
endmodule
