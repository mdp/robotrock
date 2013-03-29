while true
do
  source ./.env && ./bin/hubot -a gtalk -n robotrocknoe
  echo  "Hit Ctrl-C again to exit, otherwise I'll update to master and restart"
  sleep 5
  git reset --hard
  git checkout master
  git reset origin/master --hard
  git pull origin master
done
