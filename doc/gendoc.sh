#!/bin/sh

# commands to update the document pages from homepage

lynx -dump -width 150 "http://iso2mesh.sourceforge.net/cgi-bin/index.cgi?keywords=Download&embed=1" > Download_and_License.txt
lynx -dump "http://iso2mesh.sourceforge.net/cgi-bin/index.cgi?keywords=Doc/Installation&embed=1" > INSTALL.txt
lynx -dump "http://iso2mesh.sourceforge.net/cgi-bin/index.cgi?keywords=Doc/Basics&embed=1" > Get_Started.txt
lynx -dump "http://iso2mesh.sourceforge.net/cgi-bin/index.cgi?keywords=Doc/FAQ&embed=1" > FAQ.txt

wget http://iso2mesh.sourceforge.net/upload/iso2mesh_workflow_v09.jpg -Oiso2mesh_workflow.jpg
