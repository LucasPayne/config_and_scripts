#--------------------------------------------------------------------------------
# gdbinit.py
# This is exec'd by the .gdbinit prelude.
#--------------------------------------------------------------------------------
import gdb

class UserCommand:
    def __init__(self, name, commands):
        self.name = name
        self.commands = commands
    def run(self, args):
        command_line=" ".join([command] + args)
        return gdb.execute(command_line, )

def gdb_define_command(name, commands):
    gdb.execute("define {}".format(name))
    for command in commands:
        gdb.execute(command)
    gdb.execute("end")
 
def main():
    # Command to source .gdbinit file.
    gdb_define_command("sg", ["source ~/.gdbinit"])

main()
