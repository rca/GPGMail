#!/usr/bin/env python

import sys
from time import time
import subprocess
try:
    from macholib import MachO
    import macholib
except ImportError, e:
    print "Python library macholib is missing. Abort!"
    sys.exit(0)
import os

KEY_ID = "85E3 8F69 046B 44C1 EC9F B07B 76D7 8F05 00D0 26C4"

def data_to_sign(executable):
    def find_segment_in_header_cmds(header_cmds, segname):
        for cmd in header_cmds:
            if isinstance(cmd[1], macholib.mach_o.segment_command_64) and cmd[1].segname.startswith(segname):
                return (cmd[1], cmd[1].nsects > 0 and cmd[2] or [])
        return None
    
    def find_section_in_sections(sections, sectname):
        for section in sections:
            if section.sectname.startswith(sectname):
                return section
        
        return None
    
    machO = MachO.MachO(executable)
    header = machO.headers[0]
    (textSegment, textSections) = find_segment_in_header_cmds(header.commands, "__TEXT")
    textSection = find_section_in_sections(textSections, "__text")
    expirationSection = find_section_in_sections(textSections, "__gmed_xx")
    
    fh = open(executable, "r")
    fh.seek(textSection.addr)
    data = fh.read(textSection.size)
    fh.seek(expirationSection.addr)
    expirationData = fh.read(expirationSection.size)
    
    return data + expirationData

# def add_expiration_date(path, minutes):
#     fh = open(path, "a")
#     timestamp = int(time()) + (minutes * 60)
#     fh.write("%s" % (timestamp))
#     fh.close()
    
def create_signature(path, destination):
    print destination
    if os.path.isfile(destination):
        os.unlink(destination)
    subprocess.call(["/usr/local/MacGPG2/bin/gpg2", "-bs", "-u", KEY_ID.replace(" ", ""), "--batch", "--output", destination, path])

def main():
    PRODUCT_PATH = sys.argv[1]
    EXECUTABLE = "%s/Contents/MacOS/GPGMail" % (PRODUCT_PATH)
    
    if not os.path.isdir(EXECUTABLE):
        print "Failed to add expiration date - GPGMail executable doesn't exist!"
        sys.exit(0)

    data = data_to_sign(EXECUTABLE)
    print "Data length: %d" % (len(data))
    
    original_data_file = "%s/code_data" % (PRODUCT_PATH.replace("/GPGMail.mailbundle", ""))
    fh = open(original_data_file, "w")
    fh.write(data)
    fh.close()
    
    SIG = "%s/Contents/Resources/signature-icon.gif" % (PRODUCT_PATH)
    #add_expiration_date(EXECUTABLE, int(sys.argv[1]))
    create_signature(original_data_file, SIG)
    os.unlink(original_data_file)
print "Adding GPG code signature."
main()
