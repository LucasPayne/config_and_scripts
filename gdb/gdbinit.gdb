#--------------------------------------------------------------------------------
# gdbinit prelude.
# This contains general settings, then does the minimum needed to pass
# further gdb initialization to gdbinit.py.
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Basic settings.
set print asm-demangle
# Uncomment if using a strange SHELL.
#set startup-with-shell off

#--------------------------------------------------------------------------------
# python.
# gdb's python integration provides a more powerful command language to initialize gdb,
# through gdb.execute.
# Gdb's command language is intended as an interactive debugger.
# Problems with using gdb's command language for scripting include:
#    No trailing comments at the end of a line.
# However gdb does have a sort of embedded language, with loops and interpreter variables.
#    https://stackoverflow.com/questions/46454655/how-do-i-write-a-loop-in-a-gdb-script
#--------------------------------------------------------------------------------
python
import os
import sys
from pathlib import Path

# globals
GDB_DEV=""

def initialize_globals():
    # Initialize globals needed to load scripts.
    global GDB_DEV
    GDB_DEV = os.getenv("GDB_DEV")
    if not GDB_DEV:
        print("Warning: GDB_DEV is not set. This should point to a directory where gdb stores scripts, and saves state.")
        sys.exit()
    if not Path(GDB_DEV).is_dir():
        print("Warning: GDB_DEV is set to \"{}\", which is not a directory.".format(GDB_DEV))
        sys.exit()
    state_path = Path(GDB_DEV) / Path("state")
    if not state_path.is_dir():
        print("Created state directory \"{}\"".format(state_path))
        try:
            state_path.mkdir()
        except:
            print("Warning: Failed to create gdb state directory at path \"{}\".".format(state_path))
            sys.exit()

initialize_globals()

# Pass off gdb initialization to gdbinit.py.
script_path = Path(GDB_DEV) / "scripts" / "gdbinit.py"
if not script_path.is_file():
    print("Warning: Attempted to source non-existent script \"{}\".".format(script_path))
    sys.exit()
try:
    exec(open(str(script_path)).read())
except Exception as exception:
    print("Warning: exec failed on script \"{}\" with exception:".format(script_path))
    print(exception)
    sys.exit()

end
