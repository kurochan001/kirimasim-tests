/*
:name: test_fwrite_unformatted_aggregates
:description: %u writes a packed aggregate as its equivalent vector, an unpacked structure member by member in declaration order and an unpacked union as its first member, %z writes the same data as s_vpi_vecval words, and an aggregate counts as one data item (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fwrite_unformatted_aggregates.expected
*/
// IEEE 1800-2023 §21.2.1.1: %u writes the 2-state binary form of a value, %z
// its 4-state form as an aval word and a bval word for each 32 bits, with the
// unit that holds the LSB first, each in the byte order of the host. For
// packed data they operate as on the equivalent vector; an unpacked structure
// is written member by member in declaration order, and an unpacked union as
// its first member in declaration order. The count of data items of an
// aggregate is 1, not one per member. Every 32-bit word here has four equal
// bytes, so the bytes of the file do not depend on the byte order of the host.
// The test writes a packed structure {hi 66666666, lo 77777777} with %u, an
// unpacked structure {x 11111111, y 22222222} with %u, the packed structure
// again with %z, and a union whose first member is an int 44444444 with %u,
// each followed by ":" and a decimal number in its own %0d. If the aggregate
// counted one item per member, the following %0d would take the wrong
// argument. The file is read back byte by byte and printed in hex.

module test_fwrite_unformatted_aggregates;
  typedef struct packed {
    logic [31:0] hi;
    logic [31:0] lo;
  } pair_t;
  typedef struct {
    int x;
    int y;
  } two_t;
  typedef union {
    int first;
    longint second;
  } either_t;

  pair_t pk;
  two_t us;
  either_t un;
  int fd, c, n;
  logic [7:0] b;

  task automatic show(string label, int count);
    $write("%s:", label);
    for (int i = 0; i < count; i++) begin
      c = $fgetc(fd);
      b = c[7:0];
      $write(" %h", b);
    end
    $write("\n");
  endtask

  initial begin
    pk.hi = 32'h6666_6666;
    pk.lo = 32'h7777_7777;
    us.x = 32'h1111_1111;
    us.y = 32'h2222_2222;
    un.first = 32'h4444_4444;
    fd = $fopen("test_fwrite_unformatted_aggregates.bin", "wb");
    $fwrite(fd, "%u:", pk);
    $fwrite(fd, "%0d:", 5);
    $fwrite(fd, "%u:", us);
    $fwrite(fd, "%0d:", 6);
    $fwrite(fd, "%z:", pk);
    $fwrite(fd, "%0d:", 7);
    $fwrite(fd, "%u:", un);
    $fwrite(fd, "%0d", 8);
    $fclose(fd);
    fd = $fopen("test_fwrite_unformatted_aggregates.bin", "rb");
    show("packed-u", 8);
    show("mark", 3);
    show("unpacked-struct-u", 8);
    show("mark", 3);
    show("packed-z", 16);
    show("mark", 3);
    show("union-u", 4);
    show("mark", 2);
    n = 0;
    while ($fgetc(fd) != -1) n++;
    $fclose(fd);
    $display("extra bytes: %0d", n);
  end
endmodule
