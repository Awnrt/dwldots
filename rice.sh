WORKDIRECTORY=$PWD
PERMUSER="awy"

if [ "$EUID" -ne 0 ]
  then printf "The script has to be run as root.\n"
  exit
fi

DEPLIST="`sed -e 's/#.*$//' -e '/^$/d' dependencies.txt | tr '\n' ' '`"
pacman -Sy --noconfirm
pacman -S $DEPLIST --noconfirm

usermod -aG seat,input,audio,video $PERMUSER
doas -u $PERMUSER cp -r $WORKDIRECTORY/.config /home/$PERMUSER
doas -u $PERMUSER cp -r $WORKDIRECTORY/.local /home/$PERMUSER
doas -u $PERMUSER cp -a $WORKDIRECTORY/.zprofile /home/$PERMUSER

doas -u $PERMUSER mkdir -p /home/$PERMUSER/.cache/lf
doas -u $PERMUSER mkdir -p /home/$PERMUSER/.cache/zsh
doas -u $PERMUSER mkdir -p /home/$PERMUSER/.local/share/themes
doas -u $PERMUSER mkdir -p /home/$PERMUSER/.local/share/icons
doas -u $PERMUSER mkdir -p /home/$PERMUSER/.local/share/papes

cd $WORKDIRECTORY
git clone https://codeberg.org/awy/gruvbox-gtk-theme
doas -u $PERMUSER cp -r $WORKDIRECTORY/gruvbox-gtk-theme/Gruvbox-Dark /home/$PERMUSER/.local/share/themes
doas -u $PERMUSER cp -r $WORKDIRECTORY/gruvbox-gtk-theme/Gruvbox-Icons /home/$PERMUSER/.local/share/icons
rm -rf $WORKDIRECTORY/gruvbox-gtk-theme

doas -u $PERMUSER dbus-launch gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-Dark"
doas -u $PERMUSER dbus-launch gsettings set org.gnome.desktop.interface icon-theme "Gruvbox-Icons"
doas -u $PERMUSER dbus-launch gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu'
#doas -u $PERMUSER dbus-launch gsettings set org.gnome.desktop.interface font-name "Libertinus Serif 12"

cd $WORKDIRECTORY
doas -u $PERMUSER git clone https://codeberg.org/awy/dwl
cd dwl
make clean install
cd $WORKDIRECTORY
doas -u $PERMUSER git clone https://codeberg.org/awy/someblocks
cd someblocks
make clean install
cd $WORKDIRECTORY
doas -u $PERMUSER git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
mkdir -p /usr/share/zsh/plugins
cp -rf fast-syntax-highlighting /usr/share/zsh/plugins
cd ..
rm -rf dwldots

doas -u $PERMUSER mkdir -p /home/$PERMUSER/.ssh
doas -u $PERMUSER mkdir -p /home/$PERMUSER/.gnupg
doas -u $PERMUSER touch /home/$PERMUSER/.ssh/config
doas -u $PERMUSER touch /home/.gnupg/gpg-agent.conf
echo 'Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"' > /home/$PERMUSER/.ssh/config
echo 'enable-ssh-support' > /home/$PERMUSER/.gnupg/gpg-agent.conf
rc-update add sshd default
rc-service sshd start

chsh -s /bin/zsh $PERMUSER

mkdir -p /root/.config/nvim
cat <<EOL >> /root/.config/nvim/init.vim
set title
set clipboard+=unnamedplus
set relativenumber
colorscheme vim
EOL

echo "Your linux is riced!"
