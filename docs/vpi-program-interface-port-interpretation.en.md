# Program interface ports and VPI

[日本語](vpi-program-interface-port-interpretation.md)

<a id="program-interface-port-ownership"></a>

## Diagram relations and port connections

The diagram in IEEE 1800-2023 clause 37.9 shows iterations from a program to an interface and an interface array, with `vpiInstance` in the reverse direction. The program-item grammar in 24.3 and Annex A.1.7 omits interface instantiation. Program ports can connect interfaces instantiated outside the program. Clause 37.10 says that `vpiInstance` returns the immediate instance in which an object is instantiated.

- Reading a includes connected ports in the iterations shown in 37.9. Under this reading, `vpiInstance` returns the program from objects obtained through those iterations and returns the declaring instance from a separately obtained physical instance.
- Reading b applies the diagram to instances owned by the program. Connecting an external interface through a port preserves its ownership, and this reading finds no requirement to create a separate program-side object for the iteration.

The two tests follow reading a with scalar and array connections. Ghost read the expected HDL values, returned the declaring module as the owner of the physical instances, and returned empty iterations from the program. Ghost and Slang 12.0.0 rejected a control that instantiates an interface directly in the program body. The four requirements remain unmapped pending clarification of the diagram’s application to ports. [Observed results](../coverage/qualification/vpi-program-checkpoint-20261125-ghost-observations.json)
