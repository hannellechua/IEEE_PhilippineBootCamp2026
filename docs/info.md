# Tiny Cyberdeck — Interactive 8-Bit Logic Core

Tiny Cyberdeck is an interactive digital logic project designed for Tiny Tapeout using Wokwi. It demonstrates direct and inverted combinational logic through user-controlled inputs and a 7-segment visual output.

## How it works

Tiny Cyberdeck uses the first four input switches, IN0-IN3, as its primary user inputs.

Each input produces two outputs simultaneously:

- IN0-IN3 are passed directly to OUT0-OUT3.
- IN0-IN3 also pass through NOT gates, producing their complementary values on OUT4-OUT7.

This gives the circuit eight output signals from four user-controlled inputs.

The eight outputs are connected to the A-G segments and decimal point of a common-cathode 7-segment display. As the input switches are changed, the combination of direct and inverted signals changes the illuminated segments, creating different visual patterns.

The logic mapping is:

- IN0 → OUT0 and NOT(IN0) → OUT4
- IN1 → OUT1 and NOT(IN1) → OUT5
- IN2 → OUT2 and NOT(IN2) → OUT6
- IN3 → OUT3 and NOT(IN3) → OUT7

This project demonstrates basic combinational digital logic, signal inversion, complementary outputs, and visual hardware feedback.

## How to test

1. Start the Wokwi simulation.
2. Locate the 8-position DIP switch.
3. Toggle SW1-SW4 individually or in different combinations.
4. Observe the 7-segment display as the switches are changed.
5. SW1-SW4 directly control OUT0-OUT3.
6. The inverted values of SW1-SW4 simultaneously control OUT4-OUT7.
7. Verify that changing a switch changes both its direct output and its complementary output.

Different combinations of SW1-SW4 will create different patterns on the 7-segment display.

SW5-SW8 are connected to the remaining Tiny Tapeout input pins but are not used by the current logic core.

## External hardware

No additional physical external hardware is required.

The Wokwi simulation uses:

- An 8-position DIP switch for user input
- A common-cathode 7-segment display for visual output

The project is implemented using the Tiny Tapeout Wokwi digital-design flow.
