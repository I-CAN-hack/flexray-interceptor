#!/usr/bin/env python3
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert VCD file to VHDL statements')
    parser.add_argument("-i", "--input", required=True)
    args = parser.parse_args()

    timescale = "0 ns"
    prev_t = 0
    r = ""

    with open(args.input) as f:
        for i, line in enumerate(f):
            line = line.rstrip()
            if i == 0:
                wires = line.split(", ")[1:]
                wires = [w.replace(' ', '_').lower() for w in wires]
                continue

            vs = line.split(', ')
            t = int(float(vs[0]) * 1e9)
            vs = vs[1:]

            dt = t - prev_t

            dt = min(dt, 1000000)

            if dt > 0:
                r += f"wait for {dt} ns;\n"

            for i, v in enumerate(vs):
                r += f"{wires[i]} <= '{v}';\n"

            prev_t = t

    print(r)
