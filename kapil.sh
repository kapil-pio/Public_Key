#!/QOpenSys/usr/bin/bash
# ------------------------------------------------------------------------- #
# Program       : init.sh
# Author        : Ravisankar Pandian
# Company       : Programmers.io
# Date Written  : 24/05/2024
# Copyright     : Programmers.io
# Description   : This script sets up all the necessary things required for DevOps Development
# ------------------------------------------------------------------------- #

#################################################################################
# Function to print the progress bar characters.
#################################################################################
progress_bar() {
  local total_work=$1
  local work_done=$2
  local progress=$((work_done*20/total_work))  # 20 because 100/5=20
  local filled_part=$(printf "%${progress}s" "")
  local empty_part=$(printf "%$((20-progress))s" "")  # 20 because 100/5=20
  printf "|%s%s| %s%%\r" "${filled_part// /#}" "${empty_part}" "$((work_done*100/total_work))"
}

#################################################################################
# Function to show the progress bar
#################################################################################
showProgress(){
  total_work=$1
  work_done=0
  while [ $work_done -lt $total_work ]; do
      # Simulate some work with sleep
      /QOpenSys/pkgs/bin/sleep 0.1
      work_done=$((work_done+1))
      progress_bar $total_work $work_done
  done
  echo ""  # Newline after progress bar
}

#################################################################################
# Function to make some gap between every action
#################################################################################
printheading(){
  echo -e "\n" 
  echo "==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-d=="
  echo "$1"
  echo "==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-=d"
}


#################################################################################
# Function to setup the user profiles
#################################################################################
createprofile(){
  # Create the user libraries first
  printheading "Create User Libraries..."
  cl CRTLIB $1 
  
  # Then create the user profiles and attach the JOBD to them
  printheading "Create user profiles..."
  echo "CRTUSRPRF USRPRF($1) PASSWORD(WELCOME) USRCLS(*SECOFR) CURLIB($1) TEXT('Developers Profile') JOBD(PROGRAMMER)"
  cl "CRTUSRPRF USRPRF($1) PASSWORD(WELCOME) USRCLS(*SECOFR) CURLIB($1) TEXT('Developers Profile') JOBD(PROGRAMMER)"

  # Setup the SSH Keys
  printheading "Setup the .ssh folder for the users..."
  mkdir -p /home/$1/.ssh  
  cd /home/$1/.ssh
  /QOpenSys/pkgs/bin/wget --show-progress https://raw.githubusercontent.com/ravisankar-PIO/gitonibmi/main/id_ed25519
  /QOpenSys/pkgs/bin/wget --show-progress https://raw.githubusercontent.com/ravisankar-PIO/gitonibmi/main/id_ed25519.pub
  chmod 600 id_ed25519
  chmod 600 id_ed25519.pub
  
  # Setup the .profile file
  cd .. && echo "export PATH=/QOpenSys/QIBM/ProdData/JavaVM/jdk17/64bit/bin:/QOpenSys/pkgs/bin:$PATH" >> .profile
  
  # Setup gitprompt on bash
  wget --show-progress https://raw.githubusercontent.com/ravisankar-PIO/gitonibmi/main/gitprompt.sh
  mv gitprompt.sh .gitprompt.sh
  echo "PROMPT_COMMAND='__posh_git_ps1 \"\${VIRTUAL_ENV:+(\`basename \$VIRTUAL_ENV\`)}\\[\\e[32m\\]\\u\\[\\e[0m\\]@\\h:\\[\\e[33m\\]\\w\\[\\e[0m\\] \" \"\\\\\\\$ \";'\$PROMPT_COMMAND" >> .profile
  echo "source /home/$current_user/.gitprompt.sh" >> .profile

  # Change the shell to Bash for this user
  /QOpenSys/pkgs/bin/chsh -s /QOpenSys/pkgs/bin/bash $1

}




## set Open source packages' path
cd ~
echo "export PATH=/QOpenSys/pkgs/bin:$PATH" >> .profile 
source .profile

# Set bash as the default shell.
/QOpenSys/pkgs/bin/chsh -s /QOpenSys/pkgs/bin/bash $USER
printheading "Changed the default shell to bash..."

# Create the required user profiles one by one. 
createprofile "KAPIL"


# #################################################################################
# Retrieve SSH Keys from GitOnIBMi Repo
# #################################################################################
cd ~
mkdir .ssh
cd .ssh
printheading "Retrieve SSH Keypairs..."
wget --show-progress https://raw.githubusercontent.com/kapil-pio/Public_Key/refs/heads/main/id_ed25519
wget --show-progress https://raw.githubusercontent.com/kapil-pio/Public_Key/refs/heads/main/id_ed25519.pub
chmod 600 id_ed25519
chmod 600 id_ed25519.pub


# #################################################################################
# Install GIT
# #################################################################################
cd ~
printheading "Setup GIT..."
yum install git -y


# #################################################################################
# Install GIT
# #################################################################################
printheading "Clone your existing repository"
cd ~
git clone git@github.com:kapil-pio/COMMON.git

