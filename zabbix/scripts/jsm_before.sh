if [  -z $(getent group jsm) ]
then
  groupadd jsm
fi