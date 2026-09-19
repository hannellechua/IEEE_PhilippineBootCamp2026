<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Explain how your project works

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
## How it works

Tiny Cyberdeck is an interactive 8-bit combinational logic core controlled through the Tiny Tapeout input pins. The first four input switches (IN0-IN3) are used as the main user inputs.

Each input produces two outputs at the same time. IN0-IN3 are passed directly to OUT0-OUT3, while the same four inputs pass through NOT gates to generate their complementary values on OUT4-OUT7.

The eight outputs are connected to the A-G and decimal-point inputs of a 7-segment display. Changing the four input switches therefore creates different visual patterns on the display while demonstrating direct and inverted digital logic.

## How to test

1. Start the Wokwi simulation.
2. Toggle switches SW1-SW4 individually or in different combinations.
3. Observe the 7-segment display after each change.
4. SW1-SW4 directly control OUT0-OUT3.
5. Their inverted values simultaneously control OUT4-OUT7.
6. Verify that changing an input also changes its corresponding direct and complementary outputs.

Different switch combinations will produce different patterns on the 7-segment display.

## External hardware

No additional external hardware is required. The Wokwi simulation uses an 8-position DIP switch for user input and a common-cathode 7-segment display for visual output.
