#!/usr/bin/env bash

#Implement signal trap (When user presses Ctrl+C)
 cleaneup_on_cancel() {
  echo ""
  echo "User cancelled script!!"
 #Check for folder then bundle
  if [ -d "$Parent_Dir" ]; then
   echo "Bundling incomplete files into an archive!!!"
  #Create a compressed folder
   tar -czf "attendance_tracker_${input}_archive.tar.gz" "$Parent_Dir" 2>/dev/null
    echo "Deleting incomplete folder!!"
     rm -rf "$Parent_Dir"
  fi

  echo "Script cancelled succesfully"
  exit 1
}
#Run cleaneup now
 trap cleaneup_on_cancel SIGINT

#Read user input
 read -p "Project Title: " input
#Validate user input 
if [ -z "$input" ]; then
  echo "Project Titile cannot be empty"
   exit 1
fi

#Create path variable for parent directory
 Parent_Dir="attendance_tracker_${input}"

#Check if directory exist
 if [ -d "$Parent_Dir" ]; then
  echo "Directory $Parent_Dir already exists"
  exit 1
 fi

#Create parent directory
 mkdir -p "attendance_tracker_${input}"

#Create sub-directories and check for permissions
 if ! mkdir -p "$Parent_Dir/Helpers" "$Parent_Dir/reports" 2>/dev/null; then
  echo "Cannot create directories"
  exit 1
 fi

#Create empty files within the sub-directories
 touch "$Parent_Dir/attendance_checker.py"
 touch "$Parent_Dir/Helpers/assets.csv"
 touch "$Parent_Dir/Helpers/config.json"
 touch "$Parent_Dir/reports/reports.log"

# Add content into the files
 #Add into attendance_checker.py 
cat << 'EOF' > "$Parent_Dir/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')
    
    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            message = ""
            
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

 #Add into assets.csv
cat << 'EOF' > "$Parent_Dir/Helpers/assets.csv"
Email,Names,Attendance,Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,1,0
EOF

 #Add into config.json
cat << 'EOF' > "$Parent_Dir/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

 #Add into reports.log
cat << 'EOF' > "$Parent_Dir/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your
attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie
Davis, your attendance is 26.7%. You will fail this class.
EOF

#Confirm user choice
 read -p "Do you want to update attendance thresholds?(y/n): " choice

#Run as per user choice
 if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
 #Capture warning threshhold
  read -p "Enter warning threshold (default=75%): " warning
   NewWarning=${warning:-75%}
 #Capture failure threshhold (default=50%)
  read -p "Enter failure threshold (default=50%): " failure
   NewFailure=${failure:-50%}
 #Validate Numeric entry
   if [[ ! "$NewWarning" =~ ^[0-9]+%?$ ]] || [[ ! "$NewFailure" =~ ^[0-9]+%?$ ]]; then
      echo "Invalid input!! Numeric Values only!"
       NewWarning="75%"
       NewFailure="50%"
   fi
 
 #Update vaues in-place
  sed -i "s/75/$NewWarning/g" "$Parent_Dir/Helpers/config.json" 
  sed -i "s/50/$NewFailure/g" "$Parent_Dir/Helpers/config.json"

  echo "Threshholds Updated Successfully" 
    echo "User input $NewWarning & $NewFailure"
 else
  echo "Using default threshhold values"
 fi

#Verify if python3 is installed
 if python3 --version >/dev/null 2>&1; then
#Create path variable for output and print a success message
 Python3_Ver=$(python3 --version)
 echo "python3 installed ($Python3_Ver)"
else
#Print a warning message
 echo "Warning: pyhton3 missing! Install now."
fi

#Check directory structure
 if [[ -f "$Parent_Dir/attendance_checker.py" && -f "$Parent_Dir/Helpers/config.json" && -f "$Parent_Dir/Helpers/assets.csv" && -f "$Parent_Dir/reports/reports.log" ]]; then
   directory_structure=Good
 else
   directory_structure=Bad
 fi

#Final confirmation
 if [ "$directory_structure" = Good ]; then
  echo "Successful project completion"
 else
  echo "Completed project with structural error!!"
 fi
