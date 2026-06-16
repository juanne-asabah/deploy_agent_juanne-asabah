 Attendance Tracker Project

-The setup project script is an automated one that creates: a fixed project directory structure, configures threshholds and validates the local system environment.

Features of my script are as follows:
 - Error Handling: Checks if the project title is empty before creating the directories (running "mkdir") to prevent overwriting an already existent one. Numeric validation also accepts entry of numeric values only when changing threshhold values.

 - Sream Editing: "read" allows user to input custom threshhold values. The script then runs "sed -i" to update existing default values (75%,50%) in config.json file.

 - Signal Trap: Incase the script is interrupted mid-execution (when user presses Ctrl+C), it catches the signal(SIGINT),activates the trap,bundles the current directory into an .tar.gz archive, which is then deleted.

 - Health Check: The script finally verifies if Python 3 is isntalled on the local system using python --version and checks if the four files do exist in the required structure.

1. Make the script executable
   chmod +x setup_project.sh
2. Execute the script
    ./setup_project.sh
3. Test the archve trigger
    ggered when a user presses Crtl+C after running the script. It'll prompt automatic archive creation and folder cleaneup.
    *1* Interception: The script stops following the lines of code and leaves execution to "cleaneup_on_cancel"
    *2* Validation:( if[ -d "$Parent_Dir" ] ) checks if the script has begun files' creation. If so, archiving begins.
    *3* Bundling: "tar" command compresses the incomplete directory, assigns a name to the archived file; "attendance_tracker_${input}_archive.tar.gz" based on user Project Title input.
    *4* Deletion: Archiving then triggers deletion of the incomplete folder/diretory
    *5* Error reporting: exit 1 terminates the code following the interruption.
