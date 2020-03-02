#!/usr/bin/env python3
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert VCD file to VHDL statements')
    parser.add_argument("-i", "--input", required=True)
    args = parser.parse_args()

    timescale = "0 ns"
    prev_t = 0
    wires = [f"wire_{i}" for i in range(8)]
    r = ""

    with open(args.input) as f:
        for line in f:
            line = line.rstrip()
            if line.startswith("$timescale"):
                timescale = line.split(" ")
                timescale = " ".join(timescale[1:3])
            elif line.startswith("$var wire"):
                names = line.split(" ")
                n = int(names[2]) - 1
                name = names[4]
                wires[n] = name

            elif line.startswith("#"):
                t, v = map(int, line[1:-1].split())
                dt = t - prev_t
                if dt > 0:
                    r += f"wait for {dt} * {timescale}; "

                n = 0
                r += f"{wires[n]} <= '{v}'; "
                prev_t = t
    print(r)
