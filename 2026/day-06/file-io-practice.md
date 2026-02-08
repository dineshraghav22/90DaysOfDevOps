a# Day 05 – Basic File I/O Practice

## Goal
Practice basic file input/output using fundamental shell commands.

This exercise covers:
- Creating a file
- Writing to a file
- Appending to a file
- Reading the full file
- Reading parts of a file



- touch notes.txt : Creates an empty file named notes.txt.
- echo "Line 1: Created notes.txt" > notes.txt :  > writes text to the file and overwrites existing content.
- echo "Line 2: Added second line using >>" >> notes.txt : >> appends text to the end of the file.
- echo "Line 3: Written using tee" | tee -a notes.txt : Displays the line in the terminal Appends it to the file (-a means append)

- cat notes.txt
Line 1: Created notes.txt
Line 2: Added second line using >>
Line 3: Written using tee
- Explanation: Displays the entire contents of the file.

-  head -n 2 notes.txt : It will display firsts two line from file
 Line 1: Created notes.txt
Line 2: Added second line using >>

-  tail -n 2 notes.txt : It will display last two line from file
Line 2: Added second line using >>
Line 3: Written using tee