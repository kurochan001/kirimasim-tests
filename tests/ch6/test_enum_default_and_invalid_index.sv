/*
:name: test_enum_default_and_invalid_index
:description: An enum variable starts at the default of its base type, and so does a read of an enum array with an invalid index (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 6.19 7.4.5 8.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_enum_default_and_invalid_index.expected
*/
// IEEE 1800-2023 §6.8, Table 6-7: a variable of an enumerated type (6.19)
// starts with the default value of its base type, not with its first
// member: x for a logic [3:0] base, 0 for an int base. This holds for module
// variables, array elements and class properties (8.7). §7.4.5, Table 7-1:
// reading an array of an enum type with an invalid index gives the same
// value.

module test_enum_default_and_invalid_index;
  typedef enum logic [3:0] {BOOT = 4'ha, RUN, STOP} m_t;
  typedef enum {I0 = 5, I1} i_t;

  class holder;
    m_t s;
    i_t si;
  endclass

  m_t mv;
  m_t ma[2];
  i_t iv;
  m_t q[$];
  m_t aa[int];
  i_t qi[$];
  holder h;

  initial begin
    h = new;
    $display("logic base: mv=%b ma[0]=%b h.s=%b", mv, ma[0], h.s);
    $display("int base: iv=%0d h.si=%0d", iv, h.si);
    q.push_back(RUN);
    $display("invalid index: q[5]=%b aa[3]=%b qi[2]=%0d", q[5], aa[3], qi[2]);
  end
endmodule
