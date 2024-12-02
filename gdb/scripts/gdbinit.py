#--------------------------------------------------------------------------------
# gdbinit.py
# This is exec'd by the .gdbinit prelude.
#--------------------------------------------------------------------------------
import gdb

USER_COMMANDS=[]

class UserCommand:
    def __init__(self, name, commands, arg_definitions=None, documentation=""):
        if not arg_definitions:
            arg_definitions = []
        self.name = name
        self.commands = commands
        self.documentation = "User-defined function: {}\n".format(name)
        if arg_definitions:
            arg_names_and_types = [(arg, "str") if ':' not in arg else tuple(arg.split(':')) for arg in arg_definitions]
            self.documentation += "args: {}\n".format(" ".join([":".join([name, typ]) for name,typ in arg_names_and_types]))
        self.documentation += documentation
        if self.documentation[-1] != "\n":
            # The passed documentation string might not have a newline char at the last line, which should be fine for the caller to do.
            self.documentation += "\n"

    def execute(self, args, **kwargs):
        command_line=" ".join([command] + args)
        return gdb.execute(command_line, **kwargs)

    def sync(self):
        definition_string = "define {}\n{}\nend".format(self.name, "\n".join(self.commands), "end")
        gdb.execute(definition_string)
        #documentation_string = "document {}\n{}end".format(self.name, self.documentation)
        #print(documentation_string)
        #gdb.execute(documentation_string)

def gdb_define_command(name, commands, arg_definitions=None, documentation=""):
    # Note: The commands in e.g.
    #  ```define foo
    #         command
    #         command
    #     end```
    # are not executed by gdb. gdb enters a special input-processing mode which will
    # read this as one entire thing to execute, separated by newlines.
    # gdb.execute accepts newlines for this, so this multi-line syntax is invokable through the python bindings.
    global USER_COMMANDS
    command = UserCommand(name, commands, arg_definitions, documentation)
    USER_COMMANDS.append(command)
    command.sync()
    
 
def main():
    # Command to source .gdbinit file.
    gdb_define_command("sg", ["source ~/.config/gdb/gdbinit"], [], "Source the gdbinit file.")
    # Command to list user-defined commands (only those created through this python interface).
    gdb_define_command("user_commands", ["python print(USER_COMMANDS)"], [], "List user-defined commands created through the gdbinit.py python interface.")

main()

