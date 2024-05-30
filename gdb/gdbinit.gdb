set print asm-demangle

# https://stackoverflow.com/questions/8877969/why-does-gdb-start-a-new-shell-and-how-to-disable-this-behaviour
# todo:
#     vimshell should work for parameter expansion.
#     Turning this off for now as it confuses gdb.
set startup-with-shell off

# If break points are set up for every API call (for example every entry point into a shared library),
# this command will step through a trace.
# Anything useful to extract from the API call can be put in here.
define apitrace
    continue
    python
f = open("/tmp/gdb_apitrace_func", "w+")
f.write(str(gdb.selected_frame().function()))
f.close()
    end
    select-frame 1
end

define sg
    source ~/.gdbinit
end

# renderdoc
add-auto-load-safe-path /home/lucas/dev/vulkan/renderdoc/build/lib/librenderdoc.so-gdb.py

# Navigate the stack
define stack_up
    python
gdb.selected_frame().older().select()
    end
end
define stack_down
    python
gdb.selected_frame().newer().select()
    end
end

# Workaround. I think vim Termdebug might only update the source view if frame or select-frame is run (?)
define __vim_write_selected_frame_number
    python
#--------------------------------------------------------------------------------
selected_identifier = str(gdb.selected_frame())
cur = gdb.newest_frame()
counter = 0
while True:
    if str(cur) == selected_identifier:
        break
    cur = cur.older()
    counter += 1
f = open("/tmp/gdb__vim_write_selected_frame_number", "w+")
f.write(str(counter))
f.close()
#--------------------------------------------------------------------------------
    end
end


define json_serialize_stacktrace
    python
#    ,---------------------------------------------------------------------------
#   /
#  /
# /
#/ 
import json
import subprocess
import os

def serialize_frame(frame):
    val = {}

    symtab = frame.find_sal().symtab
    exit_code = 1
    if symtab:
        exit_code, result = subprocess.getstatusoutput('realpath {}'.format(symtab.filename))
    if exit_code == 0:
        val["type"] = "Source"
        val["binary"] = symtab.objfile.filename
        val["filename"] = os.path.realpath(symtab.filename)
        val["function"] = str(frame.function())
        left_paren_index = val["function"].find("(")
        if left_paren_index >= 0:
            val["function"] = val["function"][:left_paren_index]
        val["line"] = frame.find_sal().line
    else:
        val["type"] = "Binary"
        val["binary"] = gdb.solib_name(int(frame.pc()))
    return val

frames = []
cur = gdb.newest_frame()
while cur:
    frames.append(serialize_frame(cur))
    cur = cur.older()
val = {
    "frames" : frames
}
dev = os.environ["GDB_DEV"]
f = open(dev+"/state/stacktrace", "w+")
f.write(json.dumps(val, indent=2) + "\n")
f.close()
#\ 
# \
#  \
#   \
#    '---------------------------------------------------------------------------
    end
end

#--------------------------------------------------------------------------------
# pwndbg
# source /home/lucas/dev/gdb/repos/pwndbg/gdbinit.py
# set context-clear-screen


define json_serialize_breakpoints
    python
#    ,---------------------------------------------------------------------------
#   /
#  /
# /
#/ 
lines = [line.strip() for line in gdb.execute("maint info break", to_string=True).split("\n")]

import sys
import os
import re
import json

out = {}

# Extract non-pending breakpoints.
pattern = re.compile(r"^(\d+)\.(\d+)[ ]+(y|n)[ ]+(0x[0-9a-f]+)(?: in .* at ([^ ]+)).*$")
for line in lines:
    result = pattern.match(line)
    if result:
        major = result.group(1)
        minor = result.group(2)
        address = result.group(4)
        source_info = result.group(5)
        if major not in out:
            out[major] = []

        location = {}
        # location["minor"] = minor
        location["address"] = address

        # Note: Any way to do this in just the python interface?
        info_symbol_out = gdb.execute("info symbol {}".format(address), to_string=True)
        # Note: The first group should catch the "name + offset in section..." case.
        p = re.compile("(.*) in section ([^ ]*)(( of .*)?)")
        r = p.match(info_symbol_out)
        if not r:
            p = re.compile("No symbol matches .*")
            r = p.match(info_symbol_out)
            assert(r)
            # No symbol found, so assume this is a breakpoint for a stripped binary.
            location["binary"] = solib
            solib = gdb.solib_name(int(address, 16))
            assert(solib)
            location["symbol"] = None
        else:
            symbol = r.group(1)
            section = r.group(2)
            binary = r.group(3)
            if len(binary.strip()) == 0:
                # `info symbol` did not give a binary.
                # One case where this happens is if the break is on a section not yet mapped
                # into an active process address space.
                binary = "<unknown>"
            else:
                binary = binary[3:] # remove "of "
            location["binary"] = binary
            location["symbol"] = {}
            location["symbol"]["name"] = symbol
            location["symbol"]["section"] = section

        plt = symbol.endswith("@plt")
        location["plt"] = plt
        symbol_obj = gdb.lookup_global_symbol(symbol)
        if symbol_obj:
            location["source"] = {}
            location["source"]["file"] = os.path.realpath(symbol_obj.symtab.filename)
            location["source"]["line"] = symbol_obj.line
            #-Maybe the python api gives a more accurate binary?
            #location["binary"] = symbol_obj.symtab.objfile.filename
        else:
            # Parse source from `maint info break`.
            location["source"] = {}
            location["source"]["file"] = os.path.realpath("".join(source_info.split(":")[:-1]))
            location["source"]["line"] = source_info.split(":")[-1]

        out[major].append(location)

prev_out = out
out = []
for major in prev_out:
    bp = next((_bp for _bp in gdb.breakpoints() if int(_bp.number) == int(major)), None)
    val = {}
    val["number"] = bp.number
    val["locations"] = prev_out[major]
    val["expression"] = bp.location
    val["condition"] = bp.condition
    val["pending"] = False
    out.append(val)

# 
# Extract pending breakpoints.
#
for bp in gdb.breakpoints():
    if bp.pending:
        val = {}
        val["number"] = bp.number
        val["locations"] = []
        val["expression"] = bp.location
        val["condition"] = bp.condition
        val["pending"] = True
        out.append(val)

dev = os.environ["GDB_DEV"]
f = open(dev+"/state/breakpoints", "w+")
json.dump(out, f, indent=4)
f.close()
#\ 
# \
#  \
#   \
#    '---------------------------------------------------------------------------
    end
end

define sync
    json_serialize_stacktrace
    json_serialize_breakpoints
end
