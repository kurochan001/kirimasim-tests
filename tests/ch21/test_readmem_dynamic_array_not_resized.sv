/*
:name: test_readmem_dynamic_array_not_resized
:description: $readmemh and $readmemb load a dynamic array or a queue within its current size, which they do not change, whether the file holds more words or fewer (IEEE 1800-2023 Section 21.4.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4.1 21.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmem_dynamic_array_not_resized.expected
*/
// IEEE 1800-2023 §21.4.1: when a dynamic array or a queue is loaded, its
// current size is fixed and it shall not be resized. A dynamic array of 3
// words gets a file of 5 words and keeps 3, filled from its lowest index
// (21.4); a queue of 2 words gets 4 binary words and keeps 2; a dynamic array
// of 4 words gets a file of 2 words and keeps 4, the last two unchanged. The
// files are created in the current directory. Icarus Verilog 13.0 and the
// 5.052 release of Verilator do not accept a dynamic array or a queue as the
// memory of $readmemh and $readmemb.

module test_readmem_dynamic_array_not_resized;
  logic [7:0] d[];
  logic [3:0] q[$];
  logic [7:0] e[];
  int fd;

  initial begin
    fd = $fopen("test_readmem_dyn_5.mem", "w");
    $fdisplay(fd, "a1 a2 a3 a4 a5");
    $fclose(fd);
    fd = $fopen("test_readmem_dyn_q.mem", "w");
    $fdisplay(fd, "0001 0010 0011 0100");
    $fclose(fd);
    fd = $fopen("test_readmem_dyn_2.mem", "w");
    $fdisplay(fd, "b1 b2");
    $fclose(fd);

    d = new[3];
    $readmemh("test_readmem_dyn_5.mem", d);
    $display("dynamic of 3, 5 words: size=%0d %h %h %h", d.size(), d[0], d[1], d[2]);
    q = '{4'hf, 4'hf};
    $readmemb("test_readmem_dyn_q.mem", q);
    $display("queue of 2, 4 words: size=%0d %b %b", q.size(), q[0], q[1]);
    e = new[4];
    foreach (e[i]) e[i] = 8'hee;
    $readmemh("test_readmem_dyn_2.mem", e);
    $display("dynamic of 4, 2 words: size=%0d %h %h %h %h", e.size(), e[0], e[1], e[2], e[3]);
  end
endmodule
